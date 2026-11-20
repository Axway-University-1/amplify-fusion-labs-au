# Building a Multimodal (Voice-or-Text) AI Assistant with WebSocket APIs in Amplify Fusion

## Introduction

REST APIs are request/response: the client asks, the server answers, the connection closes. That is fine for CRUD operations, but it is a bad fit when a conversation needs to stay open across many turns - a chat session where the user might type, or might send a voice clip, at any point, and expects the same assistant to keep up either way.

A **WebSocket** solves this: the client opens a single TCP connection and upgrades it to a WebSocket, then both sides can send messages on that same connection at any time, in either direction, until one side closes it. 

### The Voice-or-Text AI Assistant

You will build a single WebSocket operation where, for as long as the connection stays open:

- If the inbound message is **text**, it goes straight to an AI chat model for a response
- If the inbound message is **binary (audio)**, it is transcribed to text first, then that transcript goes to the same AI chat model
- Either way, the client gets back a normal text reply, so from the client's point of view, voice and text are interchangeable ways of saying the same thing

The flow is described below:

1. The client (Postman) opens a WebSocket connection to the Fusion API
2. For as long as the connection is open, the client sends messages, each one either text or binary (audio)
3. If the message is binary, Fusion sends it to Mistral AI's Speech to Text action and gets back a transcript
4. The text message (or the transcript from Step 3) is sent to Mistral AI's Chat action
5. Fusion pushes the chat response back down the same connection
6. The client keeps sending messages - mixing typed and spoken questions - until it closes the connection

This data flow is illustrated below:

<img src="images/ws-sequence-diagram.png" alt="Sequence diagram: client opens a WebSocket connection, then while it stays open sends text or binary messages that Fusion routes through Mistral AI Speech to Text (if binary) and Mistral AI Chat, pushing each response back, until the client closes the connection" width="90%">

<!-- This is a pre-rendered PNG because Jekyll/kramdown does not render ```mermaid fences as diagrams.
     Editable source: ws-sequence-diagram.mmd (config: ws-sequence-diagram-config.json, enables text wrap to avoid label overflow).
     To regenerate after editing it:
     npx -y @mermaid-js/mermaid-cli -i ws-sequence-diagram.mmd -o images/ws-sequence-diagram.png -b white -s 3 -c ws-sequence-diagram-config.json -->

In this lab, you will learn the following:

- How to create a WebSocket API in Fusion Designer and prove out a simple request/response round trip with a Map component
- How to create the Mistral AI connections used by the full assistant use case
- How to branch a flow on whether the inbound WebSocket message is text or binary
- How to wire in Mistral AI's Speech to Text and Chat actions so voice and text converge on the same AI response
- How to test a mixed voice-and-text conversation with Postman
- How to guard the flow against a message that is neither text nor binary, and surface a failed Mistral AI transcription call as a clear reply instead of silence or a broken response
- How to review request transactions in Fusion Monitoring.

## Prerequisites

- Access to Amplify Fusion. If you do not have an account and need one, please send an email to amplify-fusion-training@axway.com with the subject line Amplify Integration Training Environment Access Request
- **Postman** (desktop, v10 or later) - recent Postman versions have a native **WebSocket Request** type alongside HTTP requests, which is what we use to test in this lab
- A **Mistral AI** account and API key - see the separate [Mistral account setup guide](mistral-account-setup.md) for step-by-step instructions
- A short pre-recorded audio clip (for example `.wav` or `.m4a`) to use as a test voice message, and its Base64-encoded form to paste into Postman's binary message box - see the [guide to recording and Base64-encoding a voice message](audio-to-base64.md) for step-by-step instructions (macOS and Windows)

---

## Lab 1 - Create the API and prove a basic WebSocket round trip

In this lab, we create a Fusion project and a new API whose frontend protocol is WebSocket instead of HTTP/REST, then prove out the simplest possible WebSocket round trip: take whatever text a client sends, stick `Axway University` onto the end of it with a **Concat** function, and send that back.

### Step 1 - Create a Fusion project

Create a new Amplify Fusion project for this lab. Use a unique name if you share the tenant with others (for example `XX_VoiceAssistant`, where `XX` is your initials). Choose **Project Type** as Fusion.

<img src="images/ws-lab1-01-create-project.png" alt="Create a Fusion project" width="50%">

### Step 2 - Create a new WebSocket API

1. In your project, click the **+** symbol next to WebSocket
2. Give it a name, for example `VoiceAssistantAPI`

<img src="images/ws-lab1-02-create-websocket-api.png" alt="Create a new WebSocket API" width="50%">

### Step 3 - Set the frontend base path

Open the API **Configuration** dialog and set a unique **Frontend Base Path**, for example `/XX_websocket`. This base path becomes part of the WebSocket URL you will connect to later (for example `wss://<your-data-plane-host>/XX_websocket`).

<img src="images/ws-lab1-03-frontend-base-path.png" alt="Set the frontend base path" width="80%">

### Step 4 - Define the operation

Click **+ Add Path** and add a single operation for the connection, for example `/assistant`, which represents the path clients connect to.

<img src="images/ws-lab1-04-define-operation.png" alt="Define the WebSocket operation" width="50%">

### Step 5 - Link an integration and add a Map component

1. On the operation, click the **link integration** button and choose **Create New Integration**

   <img src="images/ws-lab1-05-CreateNewConnection.png" alt="Clicking the link-integration icon on the /assistant path" width="40%">

2. Name it, for example `VoiceAssistantFlow`

   <img src="images/ws-lab1-05-link-integration.png" alt="Configure Linked Integration dialog naming the integration VoiceAssistantFlow" width="40%">

3. Immediately after the trigger (`WebSocket`), click the **+** symbol and add a **Map** component. Label it `Send Response`.
4. Label the WebSocket as `Invoke WebSocket`.

<img src="images/ws-lab1-05-concat-canvas.png" alt="WebSocket Invoke connected to a Map component" width="70%">

### Step 6 - Build the Concat mapping

1. Click on the Map component and maximize it to open the mapping panel
2. On the right-hand side, click **+ fx** next to `WebSocketServerResponse` and search for the **Concat** function under String.
3. Map the left-hand (Pipe In) `WebSocketServerRequest.textMessage` field into the Concat function's **inputString** field
4. On the Concat function's **concatWith** field, right-click and choose **Set Value**, then enter any text, for example your name. In this lab, we will be using `Axway University`.
5. Map the Concat function's **output** field to `WebSocketServerResponse.textMessage` (Pipe Out)
6. Click **Save and close** the map component.

<img src="images/ws-lab1-06-concat-map-config.png" alt="Map component concatenating textMessage with Axway University" width="70%">

### Step 7 - Enable and test

Go back to the WebSocket definition. Test it with Postman:

1. Activate the API and copy its URL.

<img src="images/ws-lab1-06-activate.png" alt="Activate" width="70%">

2. Connect to the WebSocket URL with a WebSocket request in Postman - use the URL you just copied and append the path (`/assistant`). Click **Connect**. Now a WebSocket connection has been made from Postman to Fusion.
3. Set the message type to **Text** and send a greeting, for example `Hello, `. Click **Send**.
4. Confirm the response comes back as your greeting with `Axway University` appended to it, for example `Hello, Axway University`

<img src="images/ws-lab1-06-postman.png" alt="Activate" width="70%">

Send a few more requests like `How are you, ` and you should see that the response always has `Axway University` appended to it.

Click on **Disconnect** after you have finished your testing and the WebSocket connection will be terminated.

At the end of Lab 1 you have an open WebSocket API and have proven the basic round trip works in Fusion.

---

## Lab 2 - Build and test the voice-or-text assistant

In this lab, we create the two Mistral AI connections the integration will call (one for transcribing audio, one for generating chat responses), build a flow that branches on whether each message is text or binary, and test both paths end to end in Postman.

> Need a Mistral account and API key first? See the [Mistral account setup guide](mistral-account-setup.md).

### Step 1 - Set up the new path

1. Deactivate the existing WebSocket that was activated earlier.
2. Add a new path and call it **/voiceassistant**
3. On this new path, click **Link Integration**, choose **Create New Integration**, and name it `VoiceAssistantFlow`

Add label to WebSocket Invoke as Invoke WebSocket.

### Step 2 - Branch on whether the message is binary

Immediately after the trigger (`WebSocket... Invoke`), add an **If-else** component labeled `Is it Binary`, with a condition expression that checks whether the inbound WebSocket message is binary. This is done by checking if the binary input is not null.

<img src="images/ws-lab2-01-If-else.png" alt="If-else adding" width="70%">

Click on the Expression inside the If-else.

Click on +Add condition and add the following condition
```
WebSocketServerRequest/binaryMessage Is Not Null
```

<img src="images/ws-lab2-02-if-else-binary.png" alt="If-else component checking for a binary message" width="70%">

Click **Save**.

### Step 3 - Binary branch: transcribe, then chat

On the **If** (binary) branch:
Click on the + to add component.

Add the **Mistral AI Transcribe - Speech to Text** component.

<img src="images/ws-lab2-01-AddMistralcomponent.png" alt="Speech-to-Text to Chat chain on the binary branch" width="70%">

Expand the properties and click **Add** next to Connection.
Provide a name to the new connection, e.g., XX_MistralConnection. Click **Create**.

Leave the endpoint URL untouched. Add a model name, e.g., `voxtral-mini-latest`.

Open the Security dropdown and add the API Key that was generated earlier. Click **Update** and test your connection.

<img src="images/ws-lab2-03-Addconnection.png" alt="Creating the Mistral Transcribe connection on the binary branch" width="70%">

A green check signifies a successful connection.
Close the newly created Mistral connection.

<img src="images/ws-lab2-03-MistralAImapping.png" alt="Mistral Transcribe connection created and tested" width="70%">

In the WebSocket properties Pipe In, join `WebSocketServerRequest.binaryMessage` to Action Properties: `MistralTranscribeInput.audio`

Click **Save and close** the Mistral AI Transcribe properties.

Label the Mistral AI Transcribe as `Convert Speech to Text`

Click on the + symbol after Mistral AI Transcribe and add a **Mistral AI - Chat** component. Label it `Generate Chat Response`.

Expand the properties of the Mistral AI component and click **Add** next to Connection.

<img src="images/ws-lab2-01-AddMistralConnectionforChat.png" alt="Add Mistral connection for chat" width="50%">

Provide a name to the new connection, e.g., `XX_MistralChat`, and an optional description. Click **Create**.

In the connection properties, leave the endpoint URL untouched.

Enter the Model Name as: `ministral-3b-latest`. Use the API Key that was generated earlier. Click **Update**.

Test your connection.

<img src="images/ws-lab2-01-MistralConnectionProperties.png" alt="Mistral connection" width="70%">

Close the connection properties.

In the Mistral component:

Join `MistralTranscribeOutput.response.message.text` from the Pipe In to Action Properties: `MistralAIChatInput.messages.text`

In the Action Properties: Set `MistralAIChatInput.prompt.text` to `Answer concisely`

Join `MistralAIChatOutput.messages.text` to `WebSocketServerResponse.textMessage`

Click **Save and close** the Mistral AI properties.

<img src="images/ws-lab2-01-MistralComponentProperties.png" alt="Mistral component properties" width="70%">

The integration must look like this.

<img src="images/ws-lab2-01-integration.png" alt="Binary branch integration: If-else, Speech to Text, and Chat components" width="70%">

### Step 4 - Activate and test the binary branch

Go back to the WebSocket API Configuration:

1. Activate the API.
2. Copy the URL.

<img src="images/ws-lab1-06-activate.png" alt="Activate" width="70%">

3. Open Postman and use the URL you had copied earlier and append the path (/voiceassistant). Click **Connect**. Now a WebSocket connection has been made from Postman to Fusion.
4. Set the message type to **Binary** and **Base64**.

   Our client, Postman, requires audio to be sent as `Base64-encoded` text rather than a raw audio file - see the [guide to recording and Base64-encoding a voice message](audio-to-base64.md) for how to produce this yourself.

   A ready-to-use example is already provided: [`audio_base64.txt`](audio_base64.txt) is the Base64-encoded form of a short recording asking "What is the capital city of India" - paste its contents into Postman's binary message box to test the binary branch end to end.

5. Click **Send** and you should get a response.

<img src="images/ws-lab2-01-Base64-encoded-Postman.png" alt="Base64Encoded-Postman-message" width="50%">

### Step 5 - Text branch: chat directly

We will now configure the Else branch to respond to a text-based chat.

Back in Fusion, Deactivate the API.
Click on **View Integration** next to /voiceassistant

<img src="images/ws-lab2-01-view-integration.png" alt="View Integration" width="50%">

On the **Else** branch:

1. Add a **Mistral AI - Chat** component, and name it `Generate Chat Response`
2. In the connection, choose the previously created Mistral Chat connection.
3. In the Pipe In, map `WebSocketServerRequest.textMessage` to Action Properties: `MistralAIChatInput.messages.text`
4. Set the Action Properties: `MistralAIChatInput.prompt.text` to `Answer concisely` and click **Save**
5. Map Action Properties: `MistralAIChatOutput.messages.text` to Pipe Out `WebSocketServerResponse.textMessage`
6. Click **Save and close** the Mistral AI properties

<img src="images/ws-lab2-01-TextMessage-Mapping.png" alt="Mapping text message" width="70%">

The final integration must look like this.

<img src="images/ws-lab2-01-FinalIntegration.png" alt="Final integration with both the binary and text branches complete" width="70%">

Activate the API

### Step 6 - Postman Mix it up (Voice and text), then disconnect

Send a few more messages, alternating text and voice, on the same connection, to confirm the API keeps handling turns without you reconnecting. Want a different spoken question for each turn? Repeat the [recording and Base64-encoding steps](audio-to-base64.md) to produce a fresh voice message. Then click **Disconnect** in Postman.

<img src="images/ws-lab2-06-postman-mixed-conversation.png" alt="A mixed text-and-voice conversation on one connection" width="70%">

A single connection that answers both a typed question and a spoken one, without reconnecting in between, confirms the full chain works: Fusion told text and audio apart, routed audio through transcription first, and always finished with the same Mistral Chat call.

---

## Lab 3 - Harden the assistant: handle unexpected messages and AI failures

In this lab, we build on the `VoiceAssistantFlow` integration from Lab 2 to handle two situations the happy-path flow ignores: an inbound WebSocket message that is neither text nor binary, and a Mistral AI transcription call that fails. Instead of a silent drop or a broken reply, the client gets back a clear, human-readable message either way.

### Step 1 - Guard against a message that is neither text nor binary

Deactivate the API, then open the `VoiceAssistantFlow` integration (**View Integration** next to `/voiceassistant`).

Click on the **If-else** component labeled `Is it Binary` and click **Add Else if**.

Add a condition to the new Else-if branch:
```
WebSocketServerRequest/textMessage Is Not Null
```
Label this branch `Is it Text`. Click **Save**.

<img src="images/ws-lab3-01-add-else-if.png" alt="Adding an Else-if branch to the If-else component" width="70%">

Drag the text branch's **Generate Chat Response** component (the Mistral AI - Chat component you built in Lab 2 Step 5) from the branch without a condition into the newly created `Is it Text` branch.

Your integration must look like this.

<img src="images/ws-lab3-01b-if-else-three-branches.png" alt="If-else with the Mistral AI - Chat action wired into the newly added Is it Text branch" width="70%">

On the remaining **Else** branch, add a **Map** component. In the pipe-out, map a fixed value into `WebSocketServerResponse.textMessage`, for example:
```
Unsupported message type. Please send a text or audio message.
```

<img src="images/ws-lab3-02-unsupported-message-map.png" alt="Map component on the Else branch returning a fixed unsupported-message reply" width="70%">

Click **Save**.

Label it `Not binary or text`.

> Postman's WebSocket client always tags what you send as either Text or Binary, so you will not be able to trigger this branch directly from Postman. It is there to protect the flow against a future message type, or a protocol-level frame, that reaches the integration with neither field populated.

### Step 2 - Check whether transcription succeeded before calling Chat

On the binary branch, click the **+** symbol immediately after **Convert Speech to Text** (before **Generate Chat Response**) and add an **If-else** component labeled `Did Transcription Succeed`.

Add a condition:
```
MistralTranscribeOutput/success = True
```

<img src="images/ws-lab3-03-transcription-success-condition.png" alt="If-else condition checking MistralTranscribeOutput success" width="70%">

Click **Save**.

Move the binary branch's existing **Generate Chat Response** component (the one you built in Lab 2 Step 3, chained after **Convert Speech to Text**) and its mapping into the **If** (success) branch - it should run exactly as it did in Lab 2.

On the **Else** branch, add a **Map** component labeled `Transcription Failed`, mapping a fixed value into the pipe out `WebSocketServerResponse.textMessage`:
```
Sorry, I couldn't understand that audio. Please try again.
```

<img src="images/ws-lab3-04-transcription-failed-map.png" alt="Map component returning a fixed message when transcription fails" width="70%">

Click **Save and close**.

The final integration must look like this

<img src="images/ws-lab3-04b-full-integration.png" alt="Full integration with the binary branch's transcription success/failure check and the text and unsupported-message branches all wired in" width="70%">

### Step 3 - Activate and test the failure paths

Activate the API.

To confirm the happy path still works, repeat the mixed text-and-voice test from Lab 2 Step 6.

Now deliberately force a failure: send an empty or corrupted binary message. You should get back the `Sorry, I couldn't understand that audio. Please try again.` reply.

<img src="images/ws-lab3-05-postman-transcription-failed-reply.png" alt="Postman showing the 'Sorry, I couldn't understand that audio. Please try again.' reply after sending an invalid binary message" width="70%">

This confirms the assistant now degrades gracefully: a malformed or unprocessable message gets a clear apology reply, rather than silence or a broken response.

### Step 4 - Review the request in Fusion Monitoring

The client only ever sees the friendly reply - but as the integration owner, you still need to see what actually failed underneath it. Open the project's **Monitor** section in Fusion and find the transactions for `/voiceassistant`.

<img src="images/ws-lab3-06-monitor-recent-transactions.png" alt="Fusion Monitor Recent Transactions list for the voiceassistant project" width="70%">

1. Click on the last transaction which was a blank binary message.
2. Click on Is it Binary +If-else
3. Click on Did Transcription Succeed +If-else
4. Click on the Map
5. Click on WebSocketServerInvokeOutput.textMessage

<img src="images/ws-lab3-07-monitor-transcription-failed-detail.png" alt="Transaction detail drilled into Is it Binary > Did Transcription Succeed, showing the Transcription Failed Map step with status SUCCESS" width="70%">

<img src="images/ws-lab3-08-monitor-map-output.png" alt="Map component detail showing WebSocketServerInvokeOutput.textMessage set to the transcription-failed apology" width="70%">

6. Now open one of your earlier, successful transactions and confirm `WebSocketServerInvokeOutput.textMessage` holds the actual chat response (for example, "The capital city of Germany is Berlin.").

<img src="images/ws-lab3-09-monitor-successful-transaction-detail.png" alt="Transaction detail showing a successful Mistral AI - Chat component execution" width="70%">

The client always gets a clean, readable reply, but nothing is hidden from you - every success and failure is still fully visible in Monitoring so you can debug it.

---

## Summary

You have built and tested a multimodal, multi-turn AI assistant over a single WebSocket connection, with no authentication anywhere on the client-facing side:

- **Lab 1** - created a WebSocket API in Fusion Designer and proved out a basic round trip with a Map component that concatenates an inbound greeting with `Axway University`
- **Lab 2** - created the two Mistral AI connections used by the flow (Speech to Text and Chat), built an integration that branches each inbound message on whether it is text or binary, routing binary messages through transcription before chat and text messages straight to chat, and tested a live, mixed conversation in Postman - typed and spoken questions, answered on the same open connection without reconnecting
- **Lab 3** - hardened the same integration against a message that is neither text nor binary, and against a failed Mistral AI transcription call, so every case gets back a clear reply instead of silence or a broken response - then reviewed both a successful and a forced-failed request in Fusion Monitoring to confirm the real success/failure detail is still fully visible behind that friendly reply

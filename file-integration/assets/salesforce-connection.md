# Salesforce connection guide

## Salesforce Setup

- If you already have a Salesforce dev or test account you can use for training, make sure it is either a developer edition, or API Access has been enabled and that you have admin rights.
- In other cases, you can **sign up** for a new salesforce developer account using <https://developer.salesforce.com/signup> for free.
  - Provide all required fields and a valid email address. \
  Make sure to use a username that is specific for the training, and **different from corporate email address** in case you use Salesforce in your organization. \
  ![salesforce02](salesforce-connection/salesforce02.png)

  - Once you click on **Sign me Up**, you will get an email with your Salesforce URL and username (you might need to wait couple minutes). Reset your password \
  ![salesforce04](salesforce-connection/salesforce04.png)

  - Verify account by clicking on **Verify Account** button in the email.

  - Set password to your account \
  ![salesforce05](salesforce-connection/salesforce05.png)

  - You are now able to login to your Salesforce developer account.

- Go to [https://login.salesforce.com](https://login.salesforce.com/) and enter your Username and Password click on **Log In**. \
  ![salesforce06](salesforce-connection/salesforce06.png)

- Open the **Setup** menu. \
  ![salesforce07](salesforce-connection/salesforce07.png)

- Under **Apps**, click on **App Manager** and click **New External Client App** for creating a new app \
  ![salesforce09](salesforce-connection/salesforce09.png).

- Fill up the required fields in the **Basic Information** \
  ![salesforce10](salesforce-connection/salesforce10.png)

- Enable **OAuth Settings** should be checked and
  - Enter the **Callback URLs**. For example, if your Amplify Studio URL is  `https://training.sandbox.fusion.services.axway.com`, your callback URL to generate tokens will be `https://training.sandbox.fusion.services.axway.com/design/oauth2/callback`.
  - Choose the following scopes in the **Available OAuth Scopes** and **Add** them to the **Selected OAuth Scopes** .
    - Full access (full)
    - Manage user data via APIs (api)
    - Perform requests at any time (refresh_token, offline_access)
  

  ![salesforce11](salesforce-connection/salesforce11.png)


- Enable **Enable Authorization Code and Credentials Flow**

In the security field
- Enable **Require secret for Web Server Flow**
- Enable **Require secret for Refresh Token Flow**

- Click on **Create** 

    ![salesforce11.3](salesforce-connection/salesforce11.3.png)

- Click on **Settings tab**
- Scroll down and open OAuth Settings
- Click on **ConsumerKey and Secret**

  ![salesforce12](salesforce-connection/salesforce12.png)
    ![salesforce12.1](salesforce-connection/salesforce12.1.png)
    
-  A new tab will ask you to verify your identity by asking you to enter the verification code sent to your email. Once you enter the code, you will be able to see the Consumer Key and Consumer Secret, which you need to save for later use in Amplify Fusion connection configuration. 
  
![salesforce12.2](salesforce-connection/salesforce12.2.png)

## Amplify Fusion Setup

You must configure a Salesforce Connection to connect Amplify Fusion to your Salesforce instance.

- From Amplify Studio, click on the + symbol next to connections. \
![salesforce13](salesforce-connection/salesforce13.png)

- Select **Connections** from the left side menu, choose the **Salesforce** connection and then click **Next**. \
![salesforce14](salesforce-connection/salesforce14.png)

- Enter the **Name**, **Description**, select the **Project** and then click **Create**. \
![salesforce15](salesforce-connection/salesforce15.png)

- To configure the connection, enter the following details:\
![salesforce16.1](salesforce-connection/salesforce16.1.png)

  - Connection Type: **OAuth 2.0 + PKCE**. This is required because Salesforce now enforces the PKCE extension for the Authorization Code flow on all External Client Apps.

  - Base URL:  **https://{subdomain}.my.salesforce.com/services/data/v{version}**. Replace your {subdomain} and {version} as follow: 

    - Subdomain: You can get your domain by clicking on the avatar on the top right corner of Salesforce application and copy **everything** that comes before ".my.salesforce.com" — including any extra segment such as `.develop` (common on Developer Edition / scratch orgs provisioned via org farm, e.g. `orgfarm-xxxxxxxxxx-dev-ed.develop`). 
      ![salesforce17](salesforce-connection/salesforce17.png)

    - Version: Use the full version number including the decimal, e.g. **60.0** — the path must be `v60.0`. You can get the available API versions by calling the service <https://{subdomain}.my.salesforce.com/services/data> in your browser.

  - ClientID: Paste the Consumer Key of the Salesforce app

  - Client Secret: Paste the Consumer Secret of the Salesforce app, which will be saved in the encrypted format.

  - Code Challenge Method: automatically set to **SHA-256** by Amplify Fusion for the PKCE flow — no action needed.

- After entering the above details, click **Update** to save the connection details.

- Click on [Generate token] to Allow access. A pop-up window should prompt you to explicitly allow some access. Please ensure that the browser does not block pop-ups. \
![salesforce18](salesforce-connection/salesforce18.png)

- Once token is generated, click on **Test** button \
![salesforce19](salesforce-connection/salesforce19.png)

- A ![test-greencheck](salesforce-connection/test-greencheck.png) indicates a successful connection test, while an ![test-redmark](salesforce-connection/test-redmark.png) indicates wrong connection and a pop-up would provide error details.

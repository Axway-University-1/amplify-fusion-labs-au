# CLI Lab

In these labs, we will install and exercise the CLI leading to running a deployment script which will promote the project from the Deployment Lab to CHECK or LIVE. At the end of these labs, you will learn the following:

* How to install the CLI
* How to run basic CLI commands
* How to run a pre built deployment script

## Pre-requisites

* Access to Amplify Integration
  > If you do not have an account and need one, please send an email to **[amplify-fusion-training@axway.com](mailto:amplify-fusion-training@axway.com?subject=Amplify%20Fusion%20-%20Training%20Environment%20Access%20Request&body=Hi%2C%0D%0A%0D%0ACould%20you%20provide%20me%20with%20access%20to%20an%20environment%20where%20I%20can%20practice%20the%20Amplify%20Fusion%20e-Learning%20labs%20%3F%0D%0A%0D%0ABest%20Regards.%0D%0A)** with the subject line `Amplify Integration Training Environment Access Request`
* Access to the Amplify Platform at [https://platfom.axway.com](https://platfom.axway.com)
* Completion of the Deployment Course and Lab
* Access to curl (or Postman)
* Completion of the Hello World hands on labs
* Suitable role to create and run deployment jobs
  > **Note**: You will need Manager role privileges to create deployment jobs in Design mode and deploy to CHECK and LIVE and activate your integrations in CHECK and LIVE. If you run into permission issues during deployment, please reach out to your environment administrator to update your role accordingly. Full Manager access or Admin access should be sufficient.

## Lab 1

In this lab we'll create, test and version a very basic integration triggered by an HTTP/S Server GET.

* Create a new Amplify Fusion project for this deployment test. Use a unique name in case you're not the only one doing this lab on your tenant (e.g. XX_deploytest with XX being your name or initials).
* Create an integration (e.g. test)
* Add an HTTP/S Server Get for the Event
![lab1](images/lab1-event-1.png)
* Click Add to create a new HTTP/S Server Connection (e.g. http server)
* Select `HTTPS` for Protocol and `Token` for Authentication and enter `12345` for the Token and click Update
![lab1](images/lab1-httpserver-connection-settings-1.png)
* Return to the integration and click on the HTTP/S Server Get component and click refresh and select the HTTP/S Server Connection you just created
* Enter `test` for the Resource Path.
  > Note that the resource path must be unique for your tenant. Since you are most likely working in a shared environment, you may want to prefix the resource path with your initials to make it unique (e.g. XX_test) \
![lab1](images/lab1-httpserver-coomponent-settings-1.png)
  > Note that your Resource Path must be unique for your tenant. You can prefix with your initials to help ensure uniqueness (e.g. `lb_test`)
* Click on Response and set Body to `Hello from V1`, set Content Type to `text/plain`, check `Send Response before flow execution` and click Save
![lab1](images/lab1-httpserver-coomponent-settings-2.png)
* Activate your integration and copy your URL and call it using curl as follows:
![lab1](images/lab1-url-1.png)
  ```bash
  curl "{YOUR INTEGRATION URL}" --header "Authorization: Bearer 12345"
  ```
  The response should be `Hello from V1`

Now that our integration is working, let's version it

* Deactivate the integration
* Click the History button in your Project and click Create New Version
* Enter a version description (e.g. initial commit) and click Save
![lab1](images/lab1-create-v1-1.png)
![lab1](images/lab1-create-v1-2.png)

## Lab 4 - Challenge yourself!

In this lab, you will explore connection overrides and add that to the script so that the credentials can be updated through a CI/CD pipeline.

Hints:
* An HTTP Server connection override [export file](https://raw.githubusercontent.com/Axway-University-1/amplify-fusion-labs-au/main/cli/assets/http_server_override.json) and a revised [import file](https://raw.githubusercontent.com/Axway-University-1/amplify-fusion-labs-au/main/cli/assets/http_server_override_modified.json) are provided as examples
* You need to add two new script inputs for the HTTPS connection Basic auth username and password
# Workshop pre-work

## Prep for your upcoming F5/NGINX Workshop

If you're here that probably means you are currently in, or registered for, an upcoming NGINXperts Workshop. By taking the time to run through this exercise you are helping us save time during the workshop and ensure that you meet the prerequisites to access the workshop. We appreciate you taking time to check your system and your access.

<br/>

## Step 0: If this is your first time in an F5 Hosted Workshop

Look for an email from **`courses@notify.udf.f5.com`**. This will have instructions on how you can login into UDF (F5 workshop environment).

![Ultra Super Important Invite email](media/megasuperimportantemail.png)

### If you cannot find your invite email ("UDF Course Registration:NGINXperts Lab ...") STOP

- These commonly get caught by spam/junk filters. *Make sure to check your spam folder **and** your system's email Quarantine.*

- If you still cannot find your invite email, you either have not been invited to a workshop or we have an incorrect email. Please get help from whoever sent you to this page.

## Step 1: Get yourself to UDF

- Navigate to [https://udf.f5.com/](https://udf.f5.com/) and select `Invited Users`
    ![Non F5](media/udfloginnonf5.png)

- If this is your first time using UDF, use the `Sign Up` link which would take your to F5 registration page.
  
  **NOTE:** this will *not be the password to the Ubuntu Desktop or other VMs in the class!*
    ![Sign up](media/F5signup.png)

- Once you have filled in your registration details, you should be receiving an `Account Activation` email as shown below
  ![Account Activation Email](media/F5accountactivationemail.png)

- When you click on the `Activate Account` button within the activation email, you would be redirected to setup 2 factor authentication as shown below. Select your preferred authentication method.
  ![2factor Authentication prompt](media/2factorAuthentication.png)

- Once you have set up 2 factor authentication successfully, you will see a `green` checkmark on your preferred method. Click on `Finish`.
  ![2factor Confirmation](media/2factorConfirmation.png)

- If you already have an account but you can't remember your password, simply reset your password by clicking on `Forgot Password?` link.
![Non F5](media/udfloginreset.png "happens to the best of us")

## Step 2: Start the course

- Once logged into UDF, click `Launch` (This will open a new tab.)
  ![Non F5](media/courselist.png "click launch")

- And then click on `Join`
  ![Non F5](media/joinbutton.png "'Yes I'm sure'")

- Click the `DEPLOYMENT` tab at the top
![Non F5](media/almostthere.png "I'm up here")

## Step 3: RDP to the Ubuntu Jumpbox

- username: `ubuntu`
- password: `Nginx123`

THIS REQUIRES AN RDP CLIENT! If you have a Mac *and* haven't downloaded an RDP client before, here is the first-party version:

[Microsoft's RDP client on the Apple Apps Store](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466?mt=12)

- Now you just have to wait for the Ubuntu Desktop to finish booting. . .

![Non F5](media/waitforboot.png "loading. . .")

- Make sure to select a small enough resolution to see the whole screen.

![Non F5](media/launchrdp.png "almost there")

- Once you select the resolution, your browser will download an rdp file. Open this file to connect to Ubuntu Desktop.

- Accept the self-signed cert, the Ubuntu Desktop username and password will be `ubuntu` and `Nginx123`.
  
  (**NOTE:** This is *not* your UDF login username & password.)

  ![Non F5](media/useruser.png)

-------------
> **If you can't connect to the Ubuntu Desktop, *remember to shut off your VPN*, or join a non-proxied network (sometimes a guest network in the office will work)**
-------------

**For machines running Windows and attached to a domain, Windows will helpfully attempt to use your domain creds to log in, and you'll see:**

![Non F5](media/domaincreds.png "everyone has credentials.com email accounts right?")

### Click "More choices" to enter both a username and a password

![Non F5](media/domaincredsannotated.png "green arrows")

That wraps the pre-requisites.

### Authors

- Dominic Lucia - Solutions Engineer - Channels @ F5, Inc.
- Chris Akker - Solutions Architect - Community and Alliances @ F5, Inc.
- Shouvik Dutta - Solutions Architect - Community and Alliances @ F5, Inc.

-------------

Navigate to ([Lab1](../lab1/readme.md) | [Main Menu](../readme.md))

# Backup Files to Google Drive

This project provides a simple Bash script to upload files to Google Drive.
All operations, including authentication, uploading, and optional cleanup, are handled via shell scripts included in this repository.
To use this application, you must create OAuth credentials as described below.
For personal use, you do not need to submit your app for Google verification.
Just add your Google account as a **Test User** during the external access setup.

## Setting Up OAuth Credentials

1. Visit the [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Create a new project.
3. Set up OAuth credentials:
    - Select **OAuth Client ID**.
    - Set **Application Type** to **Desktop app**.
4. Configure external access:
    - Set **User Type** to **External**.
    - Add your email under **Test Users**.
5. Enable the Google Drive API:
    - In the [Google Cloud Console](https://console.cloud.google.com/apis/library), search for **Google Drive API**.
    - Click **Enable**.

This setup allows your application to access Google Drive via OAuth authentication.

---

## Installation

1. Copy the example environment file:

    ```sh
    cp .env.example .env
    ```

2. Edit the `.env` file with your credentials and settings:

    ```
    EMAIL=<youremail>@gmail.com
    CLIENT_ID=
    CLIENT_SECRET=

    LOCAL_FOLDER_PATH=./upload
    GDRIVE_FOLDER_ID=
    DELETE_ORIGIN_AFTER_UPLOAD=false

    AUTOCLEAN_OLDFILES=false
    AUTOCLEAN_DAY=3
    ```

    - `LOCAL_FOLDER_PATH`: The local directory path used to store files before uploading. Make sure this folder exists or is created before running the script.
    - `GDRIVE_FOLDER_ID`: Obtain this from your Google Drive folder URL.
    - `DELETE_ORIGIN_AFTER_UPLOAD`: Set to `true` to delete original files after upload.
    - `AUTOCLEAN_OLDFILES`: Set to `true` to automatically delete files older than a specified number of days.
    - `AUTOCLEAN_DAY`: Number of days before files are considered old.

3. Run the installation script:

    ```sh
    ./install.sh
    ```

4. Set up the Auth Code:

    - After opening the authentication login link and granting access, you will be redirected to a URL.
    - Copy the value of the `code` parameter from the redirect URL:

      ```
      http://localhost/?code=<AUTHORIZATION_CODE>
      ```

    - Paste this value into the `.env` file:

      ```
      AUTHORIZATION_CODE=
      ```

5. Run the installation script again:

    ```sh
    ./install.sh
    ```

6. If all commands complete without errors, the installation is successful.

---

## Refresh Token Expiry

- The refresh token expires after 3599 seconds (~1 hour).
- To avoid authentication issues, set up a cron job to refresh the token every 30 minutes:

    ```cron
    */30 * * * * <yourpath>/refresh.sh
    ```

---

## Usage

To upload all files from the `upload` directory, run:

```sh
./upload.sh
```

---

## AutoClean

Set up a daily cron job to automatically delete old files from your Google Drive folder:

```cron
0 1 * * * <yourpath>/clean.sh
```

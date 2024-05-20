import os
import glob
import signal
import sys
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError

# Specify scopes for drive access
SCOPES = ['https://www.googleapis.com/auth/drive.file']

# Function to handle termination signals
def signal_handler(sig, frame):
    print('Exiting gracefully', flush=True)
    sys.exit(0)

try:
    keep_container_running = os.environ.get('KEEP_CONTAINER_RUNNING', False)
    google_folder_id = os.environ.get("GOOGLE_FOLDER_ID")

    if keep_container_running:
        # Register the signal handler for SIGTERM
        signal.signal(signal.SIGTERM, signal_handler)

    # Authenticate with Google Drive using service account credentials
    credentials = service_account.Credentials.from_service_account_file('../service-account-credentials.json', scopes=SCOPES)
    drive_service = build('drive', 'v3', credentials=credentials)

    # Directory where backup files are stored
    files_dir = '/archive'

    # Ensure google_folder_id is not None
    if not google_folder_id:
        print("GOOGLE_FOLDER_ID environment variable not set", flush=True)
        raise ValueError("GOOGLE_FOLDER_ID environment variable not set.")

    # Get a list of all backup files in the directory
    files_to_export = glob.glob(os.path.join(files_dir, '*'))

    # Check if there are files to upload
    if not files_to_export:
        print("No files to upload in the archive directory", flush=True)
        raise FileNotFoundError("No files to upload in the backup directory.")

    # Upload each backup file to Google Drive
    for archive_file in files_to_export:
        # Extract file name from path
        file_name = os.path.basename(archive_file)

        # Define metadata for the file
        file_metadata = {
            'name': file_name,
            'parents': [google_folder_id]
        }

        # Upload the file with chunk size for large files
        media = MediaFileUpload(archive_file, resumable=True, chunksize=1024 * 1024)
        try:
            request = drive_service.files().create(body=file_metadata, media_body=media, fields='id')
            response = request.execute()

            print(f'Uploaded {file_name} to Google Drive. File ID: {response.get("id")}', flush=True)
        except HttpError as error:
            # Here we catch the HttpError to get the status code
            print(f'Failed to upload {file_name}. HTTP status code: {error.resp.status}', flush=True)

    if keep_container_running:
        # Wait indefinitely until a signal is received
        print('Waiting for next export', flush=True)
        signal.pause()

except FileNotFoundError as e:
    print(f"Service account credentials file not found: {e}", flush=True)
    sys.exit(1)
except ValueError as e:
    print(e, flush=True)
    sys.exit(1)
except HttpError as e:
    print(f"An HTTP error occurred: {e}", flush=True)
    sys.exit(1)
except Exception as e:
    print(f"An error occurred: {e}", flush=True)
    sys.exit(1)


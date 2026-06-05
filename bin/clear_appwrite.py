import os
import sys
import urllib.request
import urllib.error
import json

def load_env(filepath):
    env = {}
    if not os.path.exists(filepath):
        return env
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '=' in line:
                key, val = line.split('=', 1)
                env[key.strip()] = val.strip()
    return env

def make_request(url, headers, method='GET', data=None):
    req = urllib.request.Request(url, headers=headers, method=method)
    if data:
        req.data = json.dumps(data).encode('utf-8')
        req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req) as response:
            body = response.read().decode('utf-8')
            # Handle empty responses (like 204 No Content for DELETE)
            if not body:
                return response.status, {}
            return response.status, json.loads(body)
    except urllib.error.HTTPError as e:
        try:
            body = e.read().decode('utf-8')
            if not body:
                return e.code, {}
            return e.code, json.loads(body)
        except:
            return e.code, str(e)
    except Exception as e:
        return 500, str(e)

def main():
    env_path = os.path.join('assets', 'env', '.env.dev')
    env = load_env(env_path)
    
    endpoint = env.get('APPWRITE_ENDPOINT')
    project_id = env.get('APPWRITE_PROJECT_ID')
    database_id = env.get('APPWRITE_DATABASE_ID')
    bucket_id = env.get('APPWRITE_STORAGE_BUCKET_ID')
    
    if not endpoint or not project_id or not database_id:
        print("Error: Missing credentials in .env.dev file.")
        sys.exit(1)
        
    collections = {
        'Users': env.get('APPWRITE_USERS_COLLECTION_ID'),
        'Circles': env.get('APPWRITE_SKILL_CIRCLES_COLLECTION_ID'),
        'Posts & Tasks': env.get('APPWRITE_POSTS_COLLECTION_ID'),
        'Comments & Submissions': env.get('APPWRITE_COMMENTS_COLLECTION_ID'),
        'Channels': env.get('APPWRITE_CHANNELS_COLLECTION_ID'),
        'Messages': env.get('APPWRITE_MESSAGES_COLLECTION_ID'),
    }
    
    print(f"Connecting to Appwrite: {endpoint} (Project: {project_id})")
    
    headers = {
        'X-Appwrite-Project': project_id,
    }
    
    # 1. Clear database documents
    for name, col_id in collections.items():
        if not col_id:
            print(f"Skipping {name} (no ID in env)")
            continue
            
        print(f"\nFetching documents from {name} ({col_id})...")
        list_url = f"{endpoint}/databases/{database_id}/collections/{col_id}/documents?limit=100"
        status, res = make_request(list_url, headers)
        
        if status != 200:
            print(f"Failed to fetch documents from {name} (Status {status}): {res}")
            continue
            
        docs = res.get('documents', [])
        if not docs:
            print(f"No documents found in {name}.")
            continue
            
        print(f"Found {len(docs)} documents. Deleting...")
        for doc in docs:
            doc_id = doc.get('$id')
            delete_url = f"{endpoint}/databases/{database_id}/collections/{col_id}/documents/{doc_id}"
            del_status, del_res = make_request(delete_url, headers, method='DELETE')
            if del_status >= 200 and del_status < 300:
                print(f"  Deleted document {doc_id}")
            else:
                print(f"  Failed to delete document {doc_id} (Status {del_status}): {del_res}")
                
    # 2. Clear storage files
    if bucket_id:
        print(f"\nFetching files from storage bucket: {bucket_id}...")
        files_url = f"{endpoint}/storage/buckets/{bucket_id}/files?limit=100"
        status, res = make_request(files_url, headers)
        
        if status == 200:
            files = res.get('files', [])
            if not files:
                print("No files found in storage bucket.")
            else:
                print(f"Found {len(files)} files. Deleting...")
                for file_info in files:
                    fid = file_info.get('$id')
                    delete_url = f"{endpoint}/storage/buckets/{bucket_id}/files/{fid}"
                    del_status, del_res = make_request(delete_url, headers, method='DELETE')
                    if del_status >= 200 and del_status < 300:
                        print(f"  Deleted file {fid}")
                    else:
                        print(f"  Failed to delete file {fid} (Status {del_status}): {del_res}")
        else:
            print(f"Failed to fetch files from storage (Status {status}): {res}")
    else:
        print("\nSkipping storage cleanup (no APPWRITE_STORAGE_BUCKET_ID in env)")

    print("\nCleanup completed successfully!")

if __name__ == '__main__':
    main()

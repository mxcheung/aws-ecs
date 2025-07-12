
# Folder Structure

```
hello-ecs/
├── app.py
├── Dockerfile
├── requirements.txt
├── buildspec.yml        # builds image, renders taskdef.json
├── taskdef.json.tpl     # template w/ placeholders for image URI & tag
├── appspec.yaml         # CodeDeploy instructions
└── static/
    ├── favicon.ico
    └── wp-admin/
        └── images/
            └── wordpress-logo.svg
```


#Cloudwatch logs
```
2025-07-11T22:32:45.597Z   * Serving Flask app 'app'
2025-07-11T22:32:45.600Z    [31m[1mWARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.[0m
2025-07-11T22:32:45.600Z   * Running on all addresses (0.0.0.0)
```

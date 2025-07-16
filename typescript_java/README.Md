
```
.
├── lib/
│   └── pipeline-stack.ts        ← CDK stack (see below)
├── app-java/                    ← your Java app source (pom.xml, src/** etc.)
│   └── Dockerfile               ← multi‑stage build (see below)
└── buildspec.yml                ← used by CodeBuild (see below)
```

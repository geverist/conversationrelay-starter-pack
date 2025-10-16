# GitHub Integration Plan

This document outlines how to integrate the conversationrelay-starter-pack with the existing tutorial in sense-recruiting-voice-ai.

## ✅ Completed

### 1. Starter Pack Repository Structure
- ✅ Created complete Node.js/Express project structure
- ✅ Added server.js with WebSocket support
- ✅ Created skeleton handler files (voice, websocket, tools)
- ✅ Added system prompt configuration
- ✅ Created status dashboard (public/index.html)
- ✅ Comprehensive README with deployment instructions
- ✅ One-click deploy configs (Railway, Render, Heroku)
- ✅ Clean - no Claude/Anthropic references

### 2. GitHub API Functions
- ✅ `github-oauth-init.js` - Initiates GitHub OAuth flow
- ✅ `github-oauth-callback.js` - Handles OAuth redirect, stores access token
- ✅ `github-create-repo.js` - Creates student repo from template
- ✅ `github-commit.js` - Commits code at each tutorial step

## 📋 Next Steps

### Step 1: Create Template Repository on GitHub

**Action Required:** Push conversationrelay-starter-pack to your GitHub account as a template repository.

```bash
cd /Users/geverist/Documents/Twilio\ Dev/conversationrelay-starter-pack

# Initialize git (if not already)
git init

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: ConversationRelay starter pack template"

# Create GitHub repository (using gh CLI)
gh repo create geverist/conversationrelay-starter-pack \
  --public \
  --source=. \
  --remote=origin \
  --push

# Mark as template repository
gh repo edit geverist/conversationrelay-starter-pack --enable-template
```

Or manually:
1. Go to https://github.com/new
2. Name: `conversationrelay-starter-pack`
3. Public repository
4. Don't initialize with README (already exists)
5. Create repository
6. Push local code:
   ```bash
   git remote add origin https://github.com/geverist/conversationrelay-starter-pack.git
   git branch -M main
   git push -u origin main
   ```
7. Go to Settings → Check "Template repository"

### Step 2: Configure GitHub OAuth App

**Action Required:** Create a GitHub OAuth App for the tutorial to use.

1. Go to https://github.com/settings/developers
2. Click "New OAuth App"
3. Fill in:
   - **Application name:** Twilio Voice AI Workshop
   - **Homepage URL:** `https://voice-ai-workshop-clean-2236-dev.twil.io`
   - **Authorization callback URL:** `https://voice-ai-workshop-clean-2236-dev.twil.io/github-oauth-callback`
4. Click "Register application"
5. Note the **Client ID**
6. Generate a new **Client Secret** (save securely)

### Step 3: Add Environment Variables to Twilio Serverless

**Action Required:** Add GitHub OAuth credentials to your Twilio Serverless environment.

```bash
cd /Users/geverist/Documents/Twilio\ Dev/sense-recruiting-voice-ai/twilio-serverless

# Add to .env file
echo "GITHUB_CLIENT_ID=your_client_id_here" >> .env
echo "GITHUB_CLIENT_SECRET=your_client_secret_here" >> .env
echo "GITHUB_TEMPLATE_OWNER=geverist" >> .env
echo "GITHUB_TEMPLATE_REPO=conversationrelay-starter-pack" >> .env
```

Update `.env.example`:
```bash
# GitHub OAuth (for tutorial repo creation)
GITHUB_CLIENT_ID=your_github_oauth_client_id
GITHUB_CLIENT_SECRET=your_github_oauth_client_secret
GITHUB_TEMPLATE_OWNER=geverist
GITHUB_TEMPLATE_REPO=conversationrelay-starter-pack
```

### Step 4: Install axios Dependency

**Action Required:** Add axios to package.json (needed for GitHub API calls).

```bash
cd /Users/geverist/Documents/Twilio\ Dev/sense-recruiting-voice-ai/twilio-serverless
npm install axios
```

### Step 5: Update Tutorial UI (voice-ai-workshop.html)

**Changes Needed:**

#### A. Add GitHub Login to Step 1

Replace Step 1 content with:
```html
<div class="step-content">
  <h2>Step 1: Connect Your GitHub Account</h2>
  <p>We'll create a repository in your GitHub account where you'll build your voice AI project.</p>

  <div class="github-section">
    <button id="githubLoginBtn" class="primary-button">
      <svg>GitHub icon</svg>
      Login with GitHub
    </button>
    <div id="githubStatus" class="status-message" style="display: none;"></div>
  </div>

  <div id="repoCreationSection" style="display: none;">
    <h3>Create Your Repository</h3>
    <input type="text" id="repoNameInput" value="my-voice-ai-assistant" placeholder="Repository name">
    <button id="createRepoBtn" class="primary-button">Create Repository</button>
  </div>

  <div id="repoInfo" style="display: none;">
    <h3>✓ Repository Created!</h3>
    <p><strong>Repository:</strong> <a id="repoLink" target="_blank"></a></p>
    <p>All your code will be committed to this repository as you progress through the workshop.</p>
  </div>
</div>
```

#### B. Replace `commitStep()` Function

Change from Twilio Serverless deployment to GitHub commits:
```javascript
async function commitStep(stepNumber, functionCode, statusId) {
  // Instead of deploying to Twilio Serverless,
  // commit to GitHub repository

  const response = await fetch('/github-commit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      sessionToken: githubSessionToken,
      repoFullName: studentRepoFullName,
      stepNumber: stepNumber,
      files: [
        { path: 'handlers/voice-handler.js', content: functionCode }
      ],
      commitMessage: getCommitMessage(stepNumber)
    })
  });

  // Update UI to show commit success instead of deployment
}
```

#### C. Update UI Text Throughout

Replace:
- "Deploy Step X" → "Commit Step X"
- "Deploying..." → "Committing to GitHub..."
- "Deployed successfully!" → "Committed successfully!"
- "View deployment" → "View commit on GitHub"

#### D. Add GitHub Status Indicators

Show repository URL, branch, latest commit throughout the tutorial.

### Step 6: Deploy Updated Tutorial

```bash
cd /Users/geverist/Documents/Twilio\ Dev/sense-recruiting-voice-ai/twilio-serverless
twilio serverless:deploy
```

### Step 7: Test End-to-End Flow

1. Open tutorial: `https://voice-ai-workshop-clean-2236-dev.twil.io/voice-ai-workshop.html`
2. Click "Login with GitHub"
3. Authorize the OAuth app
4. Enter repository name and create
5. Verify repository appears in your GitHub account
6. Complete Step 4 - verify code commits to GitHub
7. Complete remaining steps - verify each commits successfully
8. Check final repository has all code

## 🎯 Expected Final Result

**Student Experience:**
1. Opens tutorial → Logs in with GitHub (OAuth)
2. Creates repository (auto-generated from template)
3. Completes 9 tutorial steps → Each step commits code to their repo
4. Ends with complete, working project in their own GitHub account
5. Clicks "Deploy to Railway/Render/Heroku" from their repo README
6. Has live, deployed voice AI app they built

**Benefits:**
- ✅ Student owns the code (in their GitHub account)
- ✅ No Twilio Serverless 10-second WebSocket timeout issues
- ✅ Full Node.js/Express flexibility
- ✅ Easy to customize and extend after workshop
- ✅ One-click deployment to any platform
- ✅ Portfolio-ready project with proper Git history

## 📝 Files Modified/Created

### New Files in sense-recruiting-voice-ai:
- `functions/github-oauth-init.js`
- `functions/github-oauth-callback.js`
- `functions/github-create-repo.js`
- `functions/github-commit.js`

### New Repository: conversationrelay-starter-pack
- `server.js`
- `handlers/voice-handler.js`
- `handlers/websocket-handler.js`
- `handlers/tools.js`
- `config/system-prompt.js`
- `public/index.html`
- `package.json`
- `.env.example`
- `.gitignore`
- `README.md`
- `railway.json`
- `render.yaml`
- `app.json`
- `Procfile`

### Files to Modify:
- `assets/voice-ai-workshop.html` - Replace Step 1, update commit functions, change UI text
- `package.json` - Add axios dependency
- `.env` - Add GitHub OAuth credentials
- `.env.example` - Document GitHub variables

## 🔒 Security Notes

1. **Never expose Client Secret to frontend** - Only used server-side
2. **Access tokens stored in Twilio Sync** - 1 hour TTL
3. **OAuth state parameter** - CSRF protection
4. **Session tokens** - Opaque tokens, no credentials in frontend
5. **Scopes limited** - Only `public_repo` permission requested

## 🐛 Potential Issues to Watch

1. **GitHub API rate limits** - 5,000 requests/hour (authenticated)
2. **Sync document creation limits** - Handle gracefully
3. **OAuth redirect** - Must match registered callback URL exactly
4. **Repository name conflicts** - Handle "already exists" error
5. **Commit failures** - Validate syntax before committing

## 📞 Questions?

Review this plan and let me know:
1. Should we proceed with Step 1 (push to GitHub)?
2. Any changes to the starter pack structure?
3. Any additional features needed?

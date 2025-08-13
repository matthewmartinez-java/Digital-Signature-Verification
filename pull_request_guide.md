# GitHub Pull Request Workflow

This guide explains how to submit your work via a pull request on GitHub, an essential practice for learning industry-standard workflows used in collaborative software engineering.

---

##  1. Clone the Repository in Your Local Environment or Device

This step assumes that the student has already created their private GitHub Classroom repository using the link provided by the instructor.

Depending on your setup:
- Clone your repository using HTTPs:

  ```bash
  git clone https://github.com/YOUR_USERNAME/assignment-repo.git
  cd assignment-repo
  ```

- Otherwise, clone the repository using SSH for a more secure and professional setup. To do this, you need to generate an SSH key and add it to your GitHub account. Follow these steps:

   - Check for existing keys:

      ```bash
         ls -al ~/.ssh
      ```
    - Generate a new SSH key:

      ```bash
         ssh-keygen -t ed25519 -C "your_email@example.com"
      ```
    - Start the SSH agent and add your key:

      ```bash
         eval "$(ssh-agent -s)"
         ssh-add ~/.ssh/id_ed25519
      ```
     - Copy the public key:

       ```bash
          cat ~/.ssh/id_ed25519.pub
       ```
     - Add the key to your Github account
         - Go to [settings keys in your github](https://github.com/settings/keys)
         - Create a new SSH key
         - Paste the copied key and save.
      
     - Now you can clone using SSH

       ```bash
         git clone git@github.com:YOUR_USERNAME/assignment-repo.git
         cd assignment-repo
       ```

     This setup avoids having to enter your GitHub credentials every time you push or pull, and it matches real-world practices in the software industry.

---

## 2. Create a New Branch (Always!)

Let's say you're about to begin working on Milestone 1. You should create a new branch specifically for this milestone to keep your work organized and isolated:

```bash
git checkout master
git pull origin master
git checkout -b milestone1
```

📌 Pull from `master` regularly to stay updated before creating a new branch.

> **Important** You should repeat this process for every milestone, always create a new branch when you begin working on a new milestone. This helps maintain a clean history and reflects best practices used in professional software development.

---

## 3. Make Your Changes

Edit the code, add files, etc.

```bash
# After making changes
git add .
git commit -m "Created database functional requirements for milestone 1"
```

---

## 4. Push Your Branch to GitHub

```bash
git push origin milestone1
```

---

## 5. Open a Pull Request

Once you've completed your work for a milestone (for example, **Milestone 1**), follow these steps:

1. Go to your repository on GitHub.
2. Click **"Compare & pull request"** when prompted.
3. Write a brief but clear description of what you completed in the milestone.
4. Click **"Create pull request"**.

📌 This notifies the instructor that your work is ready for review.

📌 You must open a **separate pull request for each milestone** you complete. This ensures that your progress is reviewed and graded in clearly defined stages.

> **Important:** Only the instructor or a TA can merge pull requests into the `master` branch. Students do **not** have permission to merge.

---

## 6. Wait for Review

- The instructor or TA will review and comment on your work **after the milestone deadline**. If the work is appropriate, and after a grade is assigned, they will merge it into your default branch. If more work is needed, this will be noted in the pull request comments.
- If your milestone needs more work, make the edits and push again:

  ```bash
  # Make edits
  git add .
  git commit -m "Fixed issues from feedback"
  git push origin milestone1
  ```

- Your pull request will update automatically.

---

## 7. PR Gets Merged

- Once approved, the instructor will merge your changes into the `master` branch.
- You’ll see a message like:

  ```
  Pull request successfully merged
  ```

Congratulations! You’ve completed the full GitHub pull request workflow.

---

## 💬 Tips

- Use milestones branch names: `milestone1`, `milestone2`, `milestone3`, etc.
- Pull from `master` regularly to stay updated.

  ```bash
  git checkout master
  git pull origin master
  git checkout -b milestone2
  ```

- Write clear commit messages, treat them like short summaries of your work.

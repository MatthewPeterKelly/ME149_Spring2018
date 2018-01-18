# Tutorial:  how to set up GitHub Desktop (for Windows)

This tutorial is designed to help someone who is new to GitHub clone an existing repository.
These instructions are for Windows, although they should be very similar for a Mac computer.
If you are using linux, then I strongly suggest going straight to using the command-line interface.

## Motivation
Much of the content for this course will be managed using a GitHub repository.
This will become very useful once we start getting large programs that use multiple files.
The git protocol makes it easy to keep all of the files in sync on everyone's computer.

## Create a GitHub account
- Go to [https://github.com/](https://github.com/)
- Click `Sign Up` in the upper right corner.
- Create a username, enter your email, and set a password
- Click `create account`
- On the next page, I suggest leaving the default settings unchanged
- On the next page, do the survey if you want, or skip it
- Open your email and follow the link to verify your email address

## Download GitHub desktop
- Go to [https://desktop.github.com/](https://desktop.github.com/)
- Click `Download for Windows`
- Run the downloaded file
- It will open a browser tab with a welcome page
- Click `Sign into GitHub.com`
- Log in to GitHub when it pops up the form - make sure that you've verified your email address
- Configure git for your computer - this sets information for your public commits
  - Keep the default user name, or make it *Firstname LastName*
  - Keep the default email! It is there to protect you from spam email robots.
- Finish setup

## Clone the ME149 repository
- After completing the previous steps GitHub Desktop should now be open. If not, then open it.
- Click `Clone a repository` (the right-most of the three options)
- Select the URL tab and then enter:
`https://github.com/MatthewPeterKelly/ME149_Spring2018.git`
- Set the desired file path on your computer. I suggest keeping the default setting.
- Click `Clone`
- Click on the tiny blue link in the middle of the screen `open this repository`.
- You should now see an explorer window pop up showing the files for the course. From here you can access all of the files for the course, such as the first homework assignment.

## Pull updates from a repository
- Open GitHub Desktop
- Make sure that you've selected the correct repository (eg. ME149) and branch (eg. master) in the upper left.
- In the center top of the window click `Pull origin`
  - This copies all of the changes in the repo onto your computer
- If it worked: great!
- If it didn't... then there are two likely causes:
  - you have one of the files open in a program on your computer
    - close the file, thus allowing GitHub desktop to update it
  - you made changes to a file that would be overwritten by the pull
    - option one: there is a panel on the left that shows changes. You can right click and select `discard all changes`.
    - option two: commit the changes to a new branch. This requires learning some git skills, a topic for another tutorial.

## Comments:
- Another good GUI for managing git repos is [SourceTree](https://www.sourcetreeapp.com/) by Atlassian
- Both of GitHub Desktop and SourceTree work for mac
- If you're using linux, then you should use the command line interface.
- If you would like to learn more about git, checkout the [Atlassian website](https://www.atlassian.com/git/tutorials)

# Dialogs - Overview

Dialogs are a way for characters to have interactive conversations where the player can navigate through different topics.

**Dialogs are written in separate text files** and use a **special syntax** which focuses on interactive conversations. However, you can also write normal TXR script in these files and even load in separate TXR script resources into a dialog (see the [Dialog Details page](/engine_features/dialogs_details) for more information).

At the beginning of the game all supplied dialog text files will be parsed into TXR scripts and loaded into memory.

---


## Quick Start Guide

#### 1) Create a Dialog Text File

In your *Included Files* create a new text file. You can call it however you want. For this example let's call it `dialogs.txt`.

Copy the following structure into the file:

```
=== dTest
@S
return

@1 How are you?
return

@2 Goodbye.
stop
```

Let's take a look at this structure.

* `===`: marks the start of a new dialog in the file. You can have multiple dialogs in one file as long as you start each one with `===`. In the same line you have to supply the name of the dialog. This name is later used in all of your scripts when you want to access this dialog. To avoid possible clashes with other resource names you should start your dialog names with a unique prefix. Here we use the prefix `d` for a dialog called `dTest`.
* `@S`: marks the starting point of the dialog. You can leave it out but if it is present then this part of the script is run as soon as the dialog is started.
* `@1`, `@2`, ...: mark the different dialog options. They are followed by the option text which is displayed in the dialog UI where the player can choose what to say next.
* `return`: tells the game to return to the dialog UI and display the options to the player
* `stop`: tells the game to end the current dialog and return to the normal game

Let's now add an opening sentence that the main character says when the dialog is started. Here we use `cTom` but you can use your own character name.

Modify the `@S` part like this:

```
@S
cTom: Nice to see you!
return
```

In dialog scripts you don't have to use the TXR function `say()` to make a character speak. Just write the character's script name followed by a colon and then the sentence *without quotation marks*.

> [!NOTE]
> Internally this line is converted into `cTom.say("Nice to see you!");`

Modify the `@1` and `@2` parts accordingly. You can also have other characters join the conversation by using their script names.

You have now created your first dialog. Save the file.


#### 2) Loading the Dialog into the Game

To use the dialog in game you have to load the file at the beginning of the game.

Got to `o_age`'s **Create Event** and add the line

```
dialog.load_file("dialogs.txt");
```

If you named your file differently then you have to adjust the filename.

The dialogs in this file are now parsed into the game and the name for each dialog (in our example `dTest`) is made available to your TXR scripts.


#### 3) Start the Dialog

Go to any of your TXR scripts (e.g. a click on a hotspot) and add the following line:

```
dTest.start();
```

That's it. Your dialog will be started and the script associated with the entry point (`@S`) is run. After that the dialog returns to the option selection UI. Here you can choose another option and the appropriate script is run. If you select the "Goodbye." option then the script will reach the keyword `stop` which will end the dialog and return to the normal game.


## Further Reading

Make sure to check out the page about the [Dialog Details page](/engine_features/dialogs_details) which gives an overview over all the available special keywords that you can use in dialog files and explains how you can integrate normal TXR script into dialog scripts.

Also have a look at the Dialog functions in the Script API section to see how to access/change dialog data at runtime.
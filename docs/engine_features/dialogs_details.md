# Dialogs - Details 

Make sure you read the [Dialog Overview page](/engine_features/dialogs_overview) first to get an idea about how dialogs generally work.

This section goes into detail about the **structure of a dialog script**, the special **keywords** you can use in it, and how you can link **normal TXR code into your dialog scripts**.

---


## Basic Building Blocks

Let's first go over the basic building blocks of a dialog again:

| Keyword | Effect |
|---|---|
| `===` | Starts a new dialog and has to be followed by the script name of the dialog (should start with `d`, e.g. `dMerchant`) |
| `@S` | The starting point of the conversation. Played when the dialog is started. Internally this is also dialog option 0 |
| `@1`, `@2`, ... | The dialog options that the player can choose from, each has to be followed by the text that appears on the dialog UI for this option |

In addition, there are two keywords with which you can end the current option or the complete dialog:

| Keyword | Effect |
|---|---|
| `return` | stops the current option and reactivates the dialog option UI where the player can choose another option |
| `stop` | stops the complete dialog and returns to the normal game |

> [!WARNING]
> Both of these options immediately terminate the option/dialog. The current script doesn't finish executing. This means that any code in an option that you write after such a keyword will not be executed.


## Changing Dialogs

There are also two keywords for changing from one dialog to another within a conversation:

| Keyword | Effect |
|---|---|
| `goto-dialog x` | ends the current dialog and starts dialog `x` |
| `goto-previous` | ends the current dialog and starts the dialog that was active before |

> [!TIP]
>If you use one of these commands you don't have to add a `return` or `stop` statement after them because they automatically terminate the current option and dialog.


##  Changing Option State

There are some keywords with which you can change the state of an option of the currently active dialog:

| Keyword | Effect |
|---|---|
| `option-off x` | turns option `x` off so it won't be shown to the player anymore. It can later be reactivated using `option-on x` |
| `option-on x` | turns a previously turned-off option back on again |
| `option-off-for-now x` | turns option `x` off for the remainder of the currently active conversation. Should the dialog be ended and later restarted then these options are automatically reenabled |
| `option-off-forever x` | turns option `x` off for the remainder of the game. It can never be reenabled, not even by `option-on x` |

Simply start a line with any of these keywords and they will become effective immediately.

As mentioned they only affect the currently running dialog. What if you want to turn on/off an option from another dialog resource?


## TXR Script in Dialogs

Even in dialog scripts you have the full arsenal of TXR functions at your disposal. You can use them by simply indenting the line (via space(s) or tab(s)).
Any indented line will automatically be parsed as normal TXR script.

So you could write:

```
cTom: I don't want to talk about this other thing anymore.
  dOtherConversation.set_option_state(2,eOptionOffForever);
cTom: What else did I want to talk about?
return
```

In this example the second line is indented and therefore interpreted as standard TXR script. The function `set_option_state()` is called on the dialog `dOtherConversation` and its second option is permanently disabled.

These standard TXR passages don't have to be one-liners. You can include multi-line passages as long as every line is indented by at least one space or tab.

```
cTom: Where am I standing in the room?
  if (cTom.x < Room.width / 2)
  {
    cTom.say("I'm in the left side of the room.");
  }
  else
  {
    cTom.say("I'm in the right side of the room.");
  }
cTom: Now I know where I stand.
return
```

In this example the character says some lines in the form of dialog script and some lines in the form of the normal `say()` function in TXR.

> [!NOTE]
> Remember that when you write TXR script you have to include quotation marks around the speech line and a semicolon at the end of the line, whereas in the dialog script no quotation marks and no semicolon is needed (in fact, if you included those they would become part of the line of text that the character says).

And finally there is one more keyword that you can use if you want to include larger sections of TXR script that you don't want to include in your dialog script but want to store separately:

| Keyword | Effect |
|---|---|
| `run-script name` | looks up the script function `name` and includes its output (meaning its return value) into the generated script for the dialog option |

So if you have the following function in a **Script** resource (the name of which is irrelevant):

```
function dialog_script_tom_pickup_coin()
{
  var content = @'
    cTom.animate("s_tom_pickup",0.1,eOnce,eBlock);
    cTom.add_inventory(iCoin);
  ';
  return content;
}
```

then these script lines are inserted into the dialog script if you write:

```
cTom: Oh, this coin looks nice.
run-script dialog_script_tom_pickup_coin
cTom: Now I have a shiny coin in my pocket.
```

If you use one of these ways to insert normal TXR script into dialog scripts then perhaps you want to use the special dialog script features like `goto-previous` from within the TXR script. There are four functions that you can only use in TXR scripts if they are run as part of a dialog script. These are:

| Function | Effect |
|---|---|
| `current_dialog_return()` | ends the current dialog option and returns to the UI that presents the dialog options |
| `current_dialog_goto_previous()` | ends the current dialog option and starts the previous dialog again |
| `current_dialog_goto_dialog(x)` | ends the current dialog option and starts dialog resource `x` |
| `current_dialog_stop()` | ends the current dialog option and the current dialog and returns to the normal game |

> [!WARNING]
> These functions will throw an error if used outside the context of a dialog script.

> [!WARNING]
>All of these functions immediately terminate the execution of the current dialog option script. Any code that comes after them is not executed anymore.


## Further Reading

Have a look at the Dialog functions in the Script API section to see how to access/change dialog data at runtime.
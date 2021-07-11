# Plugin: `leader-open-messages`

Allows users with the Leader trust level to always send new messages to users, regardless of user settings.

---

## Features

- Allows Leaders (trust level 4) to create new private messages to:

  - Users that have blocked the Leader who wants to send a message

  - Users that are suspended / silenced

  - Users that have hidden their profile

  - Users that have turned off private messages altogether

- This affects both the message button on the user's profile and user card, as well as the "Send @User a message" option in the flag window on any of the user's posts.

---

## Impact

### Community

This plugin is important to have on our forum, because the Leader trust level contains the Community Sages, and they are meant to give feedback to posters on forum etiquette, and have minor moderation capabilities.

Before this plugin, when they tried to draft a message to a user to provide feedback, or when they tried to send a message to the user through the flagging menu, it would only inform the Leader of the inability to send a message upon trying to send, when the message had already been drafted. This is a waste of time and also does not lead to better forum behavior from the person that the message was intended for.

### Internal

No effect, as Roblox staff members are usually also moderator or admin when they are trust level 4, which already allows them to message anyone.

### Resources

A highly negligible performance impact whenever a guardian check for creating a new private message is performed, which is considered an infrequent operation.

### Maintenance

No manual maintenance needed after installing.

---

## Technical Scope

The plugin intervenes in the guardian that decides whether a post can be created, as well as in the validation checks upon new post creation.

The prepend mechanism that is used to intervene in these checks is a standard one, and so is unlikely to break throughout Discourse updates, with the exception of the case where the names or parameter lists of `Guardian.can_send_private_message?` or `PostCreator.skip_validations?` change. Even if that happens, the forum will continue to function properly, only the plugin functionality will be broken.

The logic ensures that only users who are Leaders (i.e. trust level 4) are affected. Other forum users and permissions are not affected and abide by the same message creation permissions as usual.

#### Copyright 2020 Roblox Corporation

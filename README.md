# TwitchEmotes-335

This is a port of [Twitch Emotes v2](https://www.curseforge.com/wow/addons/twitch-emotes-v2) to WotLK (3.3.5a) legacy client.

* WotLK (3.3.5a) port: [sogladev](https://github.com/sogladev/)
* Original addon: [Twitch Emotes v2](https://www.curseforge.com/wow/addons/twitch-emotes-v2) by [ren9790](https://addons.wago.io/user/ren9790)

## Description

Shows Twitch emotes in your chat by typing them as you would into Twitch. Simply type `peepoHappy` and peepoHappy will appear in your chat.

This port adapts the popular retail addon for WotLK 3.3.5a legacy servers, maintaining full functionality while being compatible with the older client.

## Port-Specific Features

**What works in 3.3.5a:**
- [x] All emote functionality from the original addon
- [x] Minimap integration with dropdown preview
- [x] Auto-completion with Tab/Shift-Tab navigation
- [ ] Auto-completion with Arrow key navigation
- [x] Statistics page (Shift-click minimap)
- [x] Hover tooltips and Shift-click to repost emotes
- [x] Animated emotes

**Legacy Client Adaptations:**
- Compatible with WotLK 3.3.5a interface version (30300)
- Smart sizing to scale emotes to avoid graphical glitches when using multiple at once
- Uses legacy-compatible libraries and API calls

### AutoComplete notes

- Up/Down arrows can't be used to cycle suggestions.
- Pressing Enter to confirm is disabled by default. If enabled, confirming with Enter may cause the client to produce an error such as `"addon-has-been-blocked-from-an-action-only-available-to-the-blizzard-ui"`. For example, `/target` when typed in chat is blocked; Use through macros still works.
- As an alternative, Shift+J (next), Shift+K (previous), Shift+L (accept) are used for navigation.

*For detailed technical changes made to ensure 3.3.5a compatibility, see the git commit history which documents all adaptations from the original retail version.*

## Usage

Type emote names in chat as you would on Twitch (e.g., `OMEGALUL`, `Pepega`, `forsenE`).

**Auto-completion:** Type a colon `:` prefix to open a dropdown with all available emotes. Use Tab/Shift-Tab to navigate, hit colon again to select, or Enter to quick send.

**Minimap Integration:** Click the minimap button for emote previews, or Shift-click to open statistics page.

**Interactive Emotes:** Hover over emotes to see their names, or Shift-click to repost them in your chat.

## Credits

- **Original addon:** [Twitch Emotes v2](https://www.curseforge.com/wow/addons/twitch-emotes-v2) by [ren9790](https://addons.wago.io/user/ren9790)
- **3.3.5a Port:** [sogladev](https://github.com/sogladev/)
- **Emote Sources:** Twitch streamers, BTTV, FFZ, Discord, and community contributions

*This addon does not access the Twitch API - emotes are added manually by the author.*

## Version History

See `Ren - Changelog.txt` for detailed version history and emote additions.
# Slack Dota Bot
Slack Dota Bot is a bot designed to show your daily dota matches to your friends in Slack. If multiple slack users play in the same match, you will get an full rundown of the match including all heros on either team, the winner and full KDAs. Games played individually will be shown underneath with a short summary of your performance in each game.

![Dota Bot](https://raw.githubusercontent.com/chris-gooley/slack-dota-bot/master/dotabot.png)

## Installation
Slack Dota Bot requires the following:
- Web facing server with Ruby installed
- Steam API key, obtainable by following instructions here: http://steamcommunity.com/dev/ *See config/steam.yml*
- Slack Incoming Webhook which you can setup from here: https://**your-slack-subdomain**.slack.com/services. *See config/slack.yml*
- Users Dota accounts to be set to Public and their respective Dota IDs. Dota IDs can be obtained from their DotaBuff URL. *See config/players.yml*
- (Optional) Upload all icons in the images directory as custom Slack emoticons, with their filenames as emoticon shortcut (dota_abaddon for dota_abaddon.png). A Selenium Firefox macro will make this easier (not provided)

### Server Installation
- Ensure ruby is installed and is in your PATH
- Clone Slack Dota Bot into a location of your choice
- Install rubygems and bundler and run `bundle install` inside `/path/to/slack_dota_bot`
- Add a daily cron job eg: `30 22 * * * cd /path/to/slack_dota_bot && bundle exec ruby runner.rb`

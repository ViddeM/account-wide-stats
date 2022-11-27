# account-wide-stats
A wow addon to aggregate stats from all your characters.
My first wow addon, created because I wanted to count how many times I have not had Invincible drop on all my characters ;(.

Shows all the stats as the usual stats screen but aggregated for all characters on the account. 

If you hover over the number you get a character-by-character breakdown. 

Note: Due to how the wow API works (at least I haven't found around it), you have to have logged in to all your characters at least once with the addon enabled for it to work. It saves character stats on every login, this also means that stats are currently not updated live (i.e. until relog).

The addon works by typing `/stats` in the chat and the stats window will open.

Screenshots:
Main addon gui (opened upon typing `/stats`
![main_gui](https://user-images.githubusercontent.com/16452604/204159850-868eb0c6-df03-4e3d-80e6-557332d70444.png)
When hovering over a stat you get a character-by-character breakdown
![with_tooltip](https://user-images.githubusercontent.com/16452604/204159891-c095a57e-5afd-496a-a11a-0d9fa340cf15.png)
As it is account-wide, it displays stats over different realms.
![multi_realm](https://user-images.githubusercontent.com/16452604/204159968-19e96029-7e38-4d39-9f53-f2e29b59e97a.png)

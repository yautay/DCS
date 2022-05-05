-- ###########################################################
-- ###                  DISCORD BOT                        ###
-- ###########################################################

--DO NOT EDIT
function repl(dirty)
    local text =
        dirty:gsub("&", ""):gsub('"', ""):gsub("|", " "):gsub("'", ""):gsub("%%", ""):gsub("/", ""):gsub("\\", ""):gsub(
        ">",
        ""
    )
    local clean = text:gsub("<", "")
    return clean
end

function BotSay(msg)
    local message = repl(msg)
    local text =
        'C:\\DiscordSendWebhook.exe -m "' ..
        message ..
            '" -w "https://discord.com/api/webhooks/955109086117113866/6j7q16ckXUXXZ25bIqnp9-q9mAZAHiYQ8RDxjZ_7VjOkDJ0XXwTWVEzWR29hzgXhKlNE"'
    os.execute(text)
end

local notifier = require("notifier")

notifier.setup()

local most_recent_noti = nil
---@param noti Notification
local noti_subscriber = function(noti)
    print(noti.message)
    most_recent_noti = noti
end

notifier.subscribe(noti_subscriber)

T.assert_deep_eq(notifier.all(), {})

vim.info("Test 1")
-- Take out the time field for comparison
-- TODO: refine this once test utils support "selective comparison"
T.assert_eq(#notifier.all(), 1)
notifier.all()[1].time = nil
T.assert_deep_eq(notifier.all(), {
    { message = "Test 1", level = vim.log.levels.INFO }
})
T.assert_eq(notifier.latest().message, "Test 1")

vim.schedule(function()
    T.assert(most_recent_noti)
    T.assert_eq(most_recent_noti.message, "Test 1")
    
    vim.warn("Test 2")
    T.assert_eq(#notifier.all(), 2)
    notifier.all()[1].time = nil
    T.assert_deep_eq(notifier.all(), {
        { message = "Test 2", level = vim.log.levels.WARN },
        { message = "Test 1", level = vim.log.levels.INFO }
    })
    T.assert_eq(notifier.latest().message, "Test 2")
    
    vim.schedule(function()
        T.assert(most_recent_noti)
        T.assert_eq(most_recent_noti.message, "Test 2")
        
        vim.error("Test 3")
        T.assert_eq(#notifier.all(), 3)
        notifier.all()[1].time = nil
        T.assert_deep_eq(notifier.all(), {
            { message = "Test 3", level = vim.log.levels.ERROR },
            { message = "Test 2", level = vim.log.levels.WARN },
            { message = "Test 1", level = vim.log.levels.INFO }
        })
        T.assert_eq(notifier.latest().message, "Test 3")
        
        vim.schedule(function()
            T.assert(most_recent_noti)
            T.assert_eq(most_recent_noti.message, "Test 3")
            
            notifier.clear()
            T.assert_deep_eq(notifier.all(), {})
            T.assert_eq(notifier.latest(), nil)
        end)
    end)
end)

-- TODO: test out the UI
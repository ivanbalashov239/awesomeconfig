local awful = require("awful")

awful.tag._viewonly = awful.tag.viewonly

awful.tag.swap = function(tag1,tag2)
    focus = {}
    for i=1, screen.count() do 
        focus[i] = awful.tag.selected(i)
    end

    local idx1,idx2,scr2 = awful.tag.getidx(tag1),awful.tag.getidx(tag2),awful.tag.getscreen(tag2)
    awful.tag.setscreen(tag2,awful.tag.getscreen(tag1))
    awful.tag.move(idx1,tag2)
    awful.tag.setscreen(tag1,scr2)
    awful.tag.move(idx2,tag1)

    for _,f in ipairs(focus) do 
        awful.tag._viewonly(f)
    end
end

awful.tag.viewonly = function(t)
    if not t then return end
    if not awful.tag.getscreen(t) then awful.tag.setscreen(mouse.screen) end
    if awful.tag.getproperty(t,"clone_of") then
        orig = awful.tag.getproperty(t,"clone_of")
        if orig.selected then
            this_tag = awful.tag.selected(mouse.screen)
            this_tag_clone = awful.tag.getproperty(this_tag,"clone")
            awful.tag.swap(this_tag, this_tag_clone)
        end
        awful.tag.swap(t,awful.tag.getproperty(t,"clone_of"))
        awful.tag._viewonly(awful.tag.getproperty(t,"clone_of"))
    else
        awful.tag._viewonly(t)
    end
end

function addtags(tt) 
    local tags = {}
    for _,t in ipairs(tt) do 
        local props = {}
        props.layout = t.layout
        props.screen = 1
        local tag = awful.tag.add(t.name, props)
        if screen.count() == 2 then
            props.screen = 2
            props.clone_of = tag
            local clone = awful.tag.add(t.name, props)
            awful.tag.setproperty(tag, "clone", clone)
        end
        tags[_] = tag
    end
    awful.tag.viewonly(awful.tag.getproperty(tags[2],"clone"))
    awful.tag.viewonly(tags[1])
    return tags
end

return {addtags = addtags}

using Mousetrap

main() do app::Application

    entry = Entry()
    set_text!(entry, "Write here")
    connect_signal_text_changed!(entry) do self::Entry
        println("text is now: $(get_text(self))")
    end

    window = Window(app)
    set_child!(window, entry)
    present!(window)

end
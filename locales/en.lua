local Translations = {
    error = {
        not_in_range = 'Too far from the city hall',
        not_enough_money = 'You don\'t have enough money on you, you need %s cash',
        exploit_attempt = 'Attempted exploit abuse',
        player_not_online = "Player Not Online",
        already_earned_license = 'This person has already earned this license',
        invalid_type = 'That is not a valid Id type...'
    },
    success = {
        recived_license = 'You have recived your %{value} for $50',
        you_have_passed = "You have passed! Pick up your license at the town hall",
        license_granted = 'Player with ID %{id} has been granted access to a license'
    },
    info = {
        bilp_text = 'City Services',
        city_services_menu = '[E] - City Services Menu',
        id_card = 'ID Card',
        driver_license = 'Drivers License',
        weaponlicense = 'Firearms License',
        new_job = 'Congratulations with your new job! (%{job})',
        open_cityhall = '[E] Open Cityhall',
        identity = 'Identity',
        employment = 'Employment',
        city_hall = 'City Hall',
        obtain_license_identity = 'Obtain a drivers license or ID card',
        select_job = 'Select a new job',
        take_lessons = 'Take Driving Lessons',
        e_take_lessons = '[E] Take Driving Lessons',
        target_open_cityhall = 'Open Cityhall',
        price = 'Price: $%{cost}',
        item_received = 'You have received your %{label} for $%{cost}',
        email_sent = "An email has been sent to driving schools, and you will be contacted automatically",
    },
    email = {
        sender = 'Township',
        subject = 'Driving lessons request',
        message = 'Dear Instructor,<br /><br />We have just received a message that someone wants to take driving lessons<br /><br />If you are willing to teach, please contact us:<br />Name: <strong>%{firstname} %{lastname}</strong><br />Phone Number: <strong>%{phone}</strong><br/><br/>Kind regards,<br />Township Los Santos'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

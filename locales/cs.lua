local Translations = {
    error = {
        not_in_range = 'Příliš daleko od radnice',
        not_enough_money = 'Nemáte dostatek peněz, potřebujete %s hotovost',
        exploit_attempt = 'Pokus o zneužití exploitu',
        player_not_online = "Hráč není online",
        already_earned_license = 'Tato osoba již získala tuto licenci'
    },
    success = {
        recived_license = 'Získal(a) jste svoji %{value} za $50',
        you_have_passed = "Složil(a) jste! Vyzvedněte si svou licenci na radnici",
        license_granted = 'Hráči s ID %{id} byl přidělena licence'
    },
    info = {
        bilp_text = 'Městské služby',
        city_services_menu = '[E] - Menu městských služeb',
        id_card = 'Občanský průkaz',
        driver_license = 'Řidičský průkaz',
        weaponlicense = 'Zbrojní průkaz',
        new_job = 'Gratulujeme k nové práci! (%{job})',
        open_cityhall = '[E] Otevřít radnici',
        identity = 'Identita',
        employment = 'Zaměstnání',
        city_hall = 'Radnice',
        obtain_license_identity = 'Získat řidičský průkaz nebo občanský průkaz',
        select_job = 'Vybrat nové zaměstnání',
        take_lessons = 'Navštívit autoškolu',
        e_take_lessons = '[E] Navštívit autoškolu',
        target_open_cityhall = 'Otevřít radnici',
        price = 'Cena: $%{cost}',
        item_received = 'Obdržel(a) jste svoji %{label} za $%{cost}',
        email_sent = "Byl odeslán e-mail autoškolám a budete automaticky kontaktován(a)",
    },
    email = {
        sender = 'Městský úřad',
        subject = 'Žádost o autoškolu',
        message = 'Vážený instruktore,<br /><br />Právě jsme obdrželi zprávu, že někdo chce navštěvovat autoškolu.<br /><br />Pokud jste ochotni vyučovat, prosím, kontaktujte nás:<br />Jméno: <strong>%{firstname} %{lastname}</strong><br />Telefonní číslo: <strong>%{phone}</strong><br/><br/>S pozdravem,<br />Městský úřad Los Santos'
    }
}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
--translate by stepan_valic
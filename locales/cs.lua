local Translations = {
    error = {
        not_in_range = 'Příliš daleko od radnice'
    },
    success = {
        recived_license = 'Obdrželi jste %{value} za $50'
    },
    info = {
        bilp_text = 'Radnice',
        city_services_menu = '~g~E~w~ - Nabídka městských služeb',
        id_card = 'Občanský průkaz',
        driver_license = 'Řidičský průkaz',
        weaponlicense = 'Zbrojní průkaz',
        new_job = 'Gratulujeme k vaší nové práci! (%{job})'
    },
    email = {
        mr = 'Pan',
        mrs = 'Paní',
        sender = 'Město',
        subject = 'Žádost o výuku jízdy',
        message = 'Dobrý den %{gender} %{lastname}<br /><br />Právě jsme obdrželi zprávu, že chcete absolvovat autoškolu.<br />Pokud jste ochotni jít na zkoušky, kontaktujte nás:<br />Jméno: <strong>%{firstname} %{lastname}</strong><br />Telefonní číslo: <strong>%{phone}</strong><br/><br/>S pozdravem,<br />Město Los Santos'
    }
}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
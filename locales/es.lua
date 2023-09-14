local Translations = {
    error = {
        not_in_range = 'Muy lejos de la municipalidad',
        not_enough_money = 'No tienes suficiente efectivo contigo, necesitas $%{cost}',
        exploit_attempt = 'Intento de abuso de sistema',
        player_not_online = 'El jugador no está en línea',
        already_earned_license = 'Esta persona ya tiene ese tipo de licencia'
    },
    success = {
        recived_license = 'Has recibido tu %{value} por $50',
        you_have_passed = '¡Pasaste la prueba! Recoge tu licencia en la municipalidad',
        license_granted = 'Se le ha dado acceso a una licencia al jugador con ID %{id}'
    },
    info = {
        bilp_text = 'Servicios municipales',
        city_services_menu = '[E] - Servicios municipales',
        id_card = 'DNI',
        driver_license = 'Licencia de conducir',
        weaponlicense = 'Licencia para portacion de armas',
        new_job = '¡Felicidades! Ahora eres un %{job}',
        open_cityhall = '[E] Abrir municipalidad',
        identity = 'Identidad',
        employment = 'Empleo',
        city_hall = 'Municipalidad',
        obtain_license_identity = 'Obtener una licencia o identificación',
        select_job = 'Seleccionar un nuevo trabajo',
        take_lessons = 'Tomar clases de manejo',
        e_take_lessons = '[E] Tomar clases de manejo',
        target_open_cityhall = 'Abrir municipalidad',
        price = 'Precio: $%{cost}',
        item_received = 'Has recibido tu %{label} por $%{cost}',
        email_sent = 'Un correo fue enviado a las escuelas de manejo, serás contactado por un instructor cuando uno esté disponible',
    },
    email = {
        sender = 'Municipalidad',
        subject = 'Solicitud de clases de manejo',
        message = 'Querido instructor/a,<br /><br />Acabamos de recibir una solicitud para clases y prueba de manejo.<br /><br />Si estás disponible para enseñar, por favor contáctalo/a:<br /><br />Nombre: <strong>%{firstname} %{lastname}</strong><br />Numero de teléfono: <strong>%{phone}</strong><br/><br/>Saludos,<br />Ayuntamiento Los Santos'
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

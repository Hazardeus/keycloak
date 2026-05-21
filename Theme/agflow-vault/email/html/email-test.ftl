<#import "template.ftl" as layout>
<@layout.emailLayout
    kicker="test smtp"
    headline="Votre SMTP fonctionne."
    body="Si vous lisez ce message dans votre boîte, votre configuration SMTP Keycloak est correctement reliée à votre serveur de mail. Aucune action requise."
/>

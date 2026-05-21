<#import "template.ftl" as layout>
<@layout.emailLayout
    kicker="vérification e-mail"
    headline="Confirmez votre adresse."
    body="Quelqu'un — probablement vous — a créé un compte agflow avec cette adresse. Si c'était bien vous, confirmez-le ci-dessous. Sinon, ignorez ce message."
    buttonLabel="Vérifier mon adresse"
    link="${link}"
    linkExpiration=linkExpiration
    linkExpirationFormatter=linkExpirationFormatter(linkExpiration)
    footer="Si vous n'avez pas créé de compte agflow, vous pouvez ignorer ce message en toute sécurité."
/>

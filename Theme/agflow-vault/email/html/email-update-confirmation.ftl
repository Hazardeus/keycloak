<#import "template.ftl" as layout>
<@layout.emailLayout
    kicker="changement d'adresse"
    headline="Confirmez votre nouvelle adresse."
    body="Vous (ou un administrateur) avez demandé à changer l'adresse e-mail associée à votre compte agflow vers <strong>${newEmail}</strong>. Confirmez ce changement ci-dessous."
    buttonLabel="Confirmer le changement"
    link="${link}"
    linkExpiration=linkExpiration
    linkExpirationFormatter=linkExpirationFormatter(linkExpiration)
    footer="Si vous n'êtes pas à l'origine de ce changement, ignorez ce message ou contactez l'administrateur."
/>

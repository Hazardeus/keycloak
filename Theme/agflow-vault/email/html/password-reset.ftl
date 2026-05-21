<#import "template.ftl" as layout>
<@layout.emailLayout
    kicker="mot de passe oublié"
    headline="Réinitialisez votre accès."
    body="Une demande de réinitialisation de mot de passe a été reçue pour votre compte agflow. Si c'est bien vous, suivez le lien ci-dessous pour définir un nouveau mot de passe."
    buttonLabel="Réinitialiser le mot de passe"
    link="${link}"
    linkExpiration=linkExpiration
    linkExpirationFormatter=linkExpirationFormatter(linkExpiration)
    footer="Si vous n'avez rien demandé, ignorez ce message — votre mot de passe ne sera pas modifié."
/>

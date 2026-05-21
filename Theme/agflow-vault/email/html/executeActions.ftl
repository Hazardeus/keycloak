<#import "template.ftl" as layout>
<@layout.emailLayout
    kicker="action requise"
    headline="Une action est requise sur votre compte."
    body="Pour continuer à utiliser agflow, une ou plusieurs actions doivent être effectuées sur votre compte. Cliquez ci-dessous pour les exécuter en quelques secondes."
    buttonLabel="Exécuter les actions"
    link="${link}"
    linkExpiration=linkExpiration
    linkExpirationFormatter=linkExpirationFormatter(linkExpiration)
    footer="Si vous n'attendiez pas cette demande, ignorez ce message ou contactez l'administrateur."
/>

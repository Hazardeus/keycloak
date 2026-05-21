<#import "template.ftl" as layout>
<@layout.emailLayout
    kicker="lien identité fédérée"
    headline="Confirmez le lien avec ${identityProviderDisplayName!identityProviderAlias}."
    body="Vous avez demandé à associer votre compte agflow à votre identité <strong>${identityProviderDisplayName!identityProviderAlias}</strong>. Confirmez cette association ci-dessous."
    buttonLabel="Confirmer le lien"
    link="${link}"
    linkExpiration=linkExpiration
    linkExpirationFormatter=linkExpirationFormatter(linkExpiration)
    footer="Si vous n'êtes pas à l'origine de cette demande, ignorez ce message."
/>

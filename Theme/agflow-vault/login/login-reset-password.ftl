<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username') displayInfo=true; section>

    <#if section = "kicker">
        mot de passe oublié
    <#elseif section = "header">
        Réinitialisez votre accès.
    <#elseif section = "form">

        <p class="v-card-sub">
            Indiquez votre identifiant. Si un compte existe, nous vous enverrons
            un lien de réinitialisation par&nbsp;courriel.
        </p>

        <form id="kc-reset-password-form" class="v-form" action="${url.loginAction}" method="post" novalidate>

            <div class="v-field">
                <label for="username">
                    <#if !realm.loginWithEmailAllowed>${msg("username")}
                    <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                    <#else>${msg("email")}</#if>
                </label>
                <input type="text" id="username" name="username" class="v-input"
                       value="${(auth.attemptedUsername!'')}" autofocus
                       autocomplete="username"
                       spellcheck="false" autocapitalize="off"
                       aria-invalid="<#if messagesPerField.existsError('username')>true</#if>" />
                <span class="v-field-rule" aria-hidden="true"></span>
                <#if messagesPerField.existsError('username')>
                    <span class="v-field-error" role="alert">
                        ${kcSanitize(messagesPerField.get('username'))?no_esc}
                    </span>
                </#if>
            </div>

            <button class="v-btn" name="login" type="submit">
                <span class="v-btn-label">Envoyer le lien</span>
                <span class="v-btn-arrow" aria-hidden="true">→</span>
            </button>
        </form>

    <#elseif section = "info">
        <a class="v-link" href="${url.loginUrl}">
            ← Revenir à la connexion
        </a>
    </#if>
</@layout.registrationLayout>

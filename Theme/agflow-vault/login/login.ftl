<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password'); section>

    <#if section = "kicker">
        connexion
    <#elseif section = "header">
        Ouvrez votre session.
    <#elseif section = "form">

        <#if realm.password>
            <form id="kc-form-login" class="v-form" action="${url.loginAction}" method="post" novalidate>

                <#if !usernameHidden??>
                    <div class="v-field">
                        <label for="username">
                            <#if !realm.loginWithEmailAllowed>Nom d'utilisateur
                            <#elseif !realm.registrationEmailAsUsername>Adresse e-mail
                            <#else>Courriel ou nom d'utilisateur</#if>
                        </label>
                        <input tabindex="1" id="username" class="v-input" name="username"
                               value="${(login.username!'')}" type="text" autofocus
                               autocomplete="username"
                               spellcheck="false" autocapitalize="off"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                        <span class="v-field-rule" aria-hidden="true"></span>
                        <#if messagesPerField.existsError('username','password')>
                            <span class="v-field-error" role="alert">
                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                            </span>
                        </#if>
                    </div>
                </#if>

                <div class="v-field">
                    <label for="password">${msg("password")}</label>
                    <input tabindex="2" id="password" class="v-input" name="password"
                           type="password" autocomplete="current-password"
                           aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                    <span class="v-field-rule" aria-hidden="true"></span>
                </div>

                <div class="v-field-row">
                    <#if realm.rememberMe && !usernameHidden??>
                        <label class="v-check">
                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"
                                <#if login.rememberMe??>checked</#if>>
                            <span class="v-check-box" aria-hidden="true"></span>
                            <span class="v-check-lbl">${msg("rememberMe")}</span>
                        </label>
                    <#else>
                        <span></span>
                    </#if>

                    <#if realm.resetPasswordAllowed>
                        <a class="v-link" href="${url.loginResetCredentialsUrl}">
                            ${msg("doForgotPassword")}
                        </a>
                    </#if>
                </div>

                <input type="hidden" id="id-hidden-input" name="credentialId"
                       <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>

                <button tabindex="4" class="v-btn" name="login" id="kc-login" type="submit">
                    <span class="v-btn-label">${msg("doLogIn")}</span>
                    <span class="v-btn-arrow" aria-hidden="true">→</span>
                </button>
            </form>

            <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                <p class="v-register-prompt">
                    <span class="v-register-prompt-text">Pas encore de compte&nbsp;?</span>
                    <a class="v-link v-link-arrow" href="${url.registrationUrl}">
                        Créer un accès
                        <span class="v-link-arrow-glyph" aria-hidden="true">→</span>
                    </a>
                </p>
            </#if>
        </#if>

    <#elseif section = "socialProviders">

        <#if realm.password && social.providers?? && social.providers?has_content>
            <div class="v-federated">
                <p class="v-federated-rule"><span>${msg("identity-provider-login-label")}</span></p>

                <div id="kc-social-providers" class="v-federated-grid">
                    <#list social.providers as p>
                        <a class="v-federated-item" href="${p.loginUrl}">
                            <span class="v-federated-name">${p.displayName!p.alias?cap_first}</span>
                            <span class="v-federated-arrow" aria-hidden="true">→</span>
                        </a>
                    </#list>
                </div>
            </div>
        </#if>

    </#if>
</@layout.registrationLayout>

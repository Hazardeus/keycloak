<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('totp'); section>

    <#if section = "kicker">
        deuxième facteur
    <#elseif section = "header">
        Saisissez votre code.
    <#elseif section = "form">

        <p class="v-card-sub">
            Ouvrez votre application d'authentification et entrez
            le code à six&nbsp;chiffres affiché.
        </p>

        <form id="kc-otp-login-form" class="v-form" action="${url.loginAction}" method="post" novalidate>

            <#if otpLogin.userOtpCredentials?size gt 1>
                <div class="v-field">
                    <label for="kc-otp-credential">${msg("loginOtpDevice")}</label>
                    <div class="v-otp-credentials">
                        <#list otpLogin.userOtpCredentials as otpCredential>
                            <label class="v-otp-credential">
                                <input type="radio" id="kc-otp-credential-${otpCredential?index}"
                                       name="selectedCredentialId" value="${otpCredential.id}"
                                       <#if otpCredential.id = otpLogin.selectedCredentialId>checked</#if> />
                                <span class="v-otp-credential-name">${otpCredential.userLabel}</span>
                            </label>
                        </#list>
                    </div>
                </div>
            </#if>

            <div class="v-field">
                <label for="otp">${msg("loginOtpOneTime")}</label>
                <input id="otp" name="otp" class="v-input v-input-otp"
                       type="text" autofocus
                       autocomplete="one-time-code"
                       inputmode="numeric" pattern="[0-9]*"
                       spellcheck="false" autocapitalize="off"
                       aria-invalid="<#if messagesPerField.existsError('totp')>true</#if>" />
                <span class="v-field-rule" aria-hidden="true"></span>
                <#if messagesPerField.existsError('totp')>
                    <span class="v-field-error" role="alert">
                        ${kcSanitize(messagesPerField.get('totp'))?no_esc}
                    </span>
                </#if>
            </div>

            <button class="v-btn" name="login" type="submit">
                <span class="v-btn-label">${msg("doLogIn")}</span>
                <span class="v-btn-arrow" aria-hidden="true">→</span>
            </button>
        </form>

    </#if>
</@layout.registrationLayout>

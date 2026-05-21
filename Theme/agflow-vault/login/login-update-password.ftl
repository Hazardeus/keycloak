<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-confirm'); section>

    <#if section = "kicker">
        nouveau mot de passe
    <#elseif section = "header">
        Définissez votre mot de passe.
    <#elseif section = "form">

        <p class="v-card-sub">
            Choisissez un mot de passe que vous n'utilisez nulle part&nbsp;ailleurs.
        </p>

        <form id="kc-passwd-update-form" class="v-form" action="${url.loginAction}" method="post" novalidate>

            <input type="text" id="username" name="username" value="${username!''}" autocomplete="username"
                   readonly="readonly" style="display:none;" />
            <input type="password" id="password" name="password" autocomplete="current-password"
                   style="display:none;" />

            <div class="v-field">
                <label for="password-new">${msg("passwordNew")}</label>
                <input type="password" id="password-new" name="password-new" class="v-input"
                       autofocus autocomplete="new-password"
                       aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>" />
                <span class="v-field-rule" aria-hidden="true"></span>
                <#if messagesPerField.existsError('password')>
                    <span class="v-field-error" role="alert">
                        ${kcSanitize(messagesPerField.get('password'))?no_esc}
                    </span>
                </#if>
            </div>

            <div class="v-field">
                <label for="password-confirm">${msg("passwordConfirm")}</label>
                <input type="password" id="password-confirm" name="password-confirm" class="v-input"
                       autocomplete="new-password"
                       aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>" />
                <span class="v-field-rule" aria-hidden="true"></span>
                <#if messagesPerField.existsError('password-confirm')>
                    <span class="v-field-error" role="alert">
                        ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                    </span>
                </#if>
            </div>

            <#if isAppInitiatedAction??>
                <div class="v-field-row">
                    <label class="v-check">
                        <input type="checkbox" id="logout-sessions" name="logout-sessions" value="on" checked>
                        <span class="v-check-box" aria-hidden="true"></span>
                        <span class="v-check-lbl">${msg("logoutOtherSessions")}</span>
                    </label>
                </div>
            </#if>

            <button class="v-btn" type="submit">
                <span class="v-btn-label">${msg("doSubmit")}</span>
                <span class="v-btn-arrow" aria-hidden="true">→</span>
            </button>

            <#if isAppInitiatedAction??>
                <button class="v-btn v-btn-ghost" type="submit" name="cancel-aia" value="true">
                    <span class="v-btn-label">${msg("doCancel")}</span>
                </button>
            </#if>
        </form>

    </#if>
</@layout.registrationLayout>

<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>

    <#if section = "kicker">
        session expirée
    <#elseif section = "header">
        Votre session a expiré.
    <#elseif section = "form">

        <div class="v-info-block">
            <p class="v-info-text">
                ${msg("pageExpiredMsg1", '<a id="loginRestartLink" class="v-link" href="${url.loginRestartFlowUrl}">'?no_esc, '</a>'?no_esc)}
            </p>
            <p class="v-info-text">
                ${msg("pageExpiredMsg2", '<a id="loginContinueLink" class="v-link" href="${url.loginAction}">'?no_esc, '</a>'?no_esc)}
            </p>
        </div>

    </#if>
</@layout.registrationLayout>

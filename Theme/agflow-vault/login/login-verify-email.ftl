<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>

    <#if section = "kicker">
        vérification e-mail
    <#elseif section = "header">
        Confirmez votre adresse.
    <#elseif section = "form">

        <div class="v-info-block">
            <p class="v-info-text">
                ${msg("emailVerifyInstruction1",user.email)}
            </p>
            <p class="v-info-text v-info-muted">
                ${msg("emailVerifyInstruction2")}
                <a class="v-link" href="${url.loginAction}">${msg("doClickHere")}</a>
                ${msg("emailVerifyInstruction3")}
            </p>
        </div>

    </#if>
</@layout.registrationLayout>

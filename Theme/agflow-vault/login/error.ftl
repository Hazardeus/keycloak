<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>

    <#if section = "kicker">
        erreur
    <#elseif section = "header">
        Quelque chose s'est mal&nbsp;passé.
    <#elseif section = "form">

        <div class="v-info-block">
            <p class="v-info-text">
                ${kcSanitize(message.summary)?no_esc}
            </p>

            <#if client?? && client.baseUrl?has_content>
                <a class="v-btn" href="${client.baseUrl}">
                    <span class="v-btn-label">${kcSanitize(msg("backToApplication"))?no_esc}</span>
                    <span class="v-btn-arrow" aria-hidden="true">→</span>
                </a>
            </#if>
        </div>

    </#if>
</@layout.registrationLayout>

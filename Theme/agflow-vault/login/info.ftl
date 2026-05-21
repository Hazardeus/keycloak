<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>

    <#if section = "kicker">
        information
    <#elseif section = "header">
        <#if messageHeader??>${messageHeader}<#else>${message.summary}</#if>
    <#elseif section = "form">

        <div class="v-info-block">
            <p class="v-info-text">
                ${message.summary?no_esc}
                <#if requiredActions??>
                    <#list requiredActions>
                        <span>
                            <#items as reqActionItem>
                                ${msg("requiredAction.${reqActionItem}")}<#sep>, </#sep>
                            </#items>
                        </span>
                    </#list>
                </#if>
            </p>

            <#if skipLink??>
            <#else>
                <#if pageRedirectUri?has_content>
                    <a class="v-btn v-btn-ghost" href="${pageRedirectUri}">
                        <span class="v-btn-label">${kcSanitize(msg("backToApplication"))?no_esc}</span>
                        <span class="v-btn-arrow" aria-hidden="true">→</span>
                    </a>
                <#elseif actionUri?has_content>
                    <a class="v-btn" href="${actionUri}">
                        <span class="v-btn-label">${kcSanitize(msg("proceedWithAction"))?no_esc}</span>
                        <span class="v-btn-arrow" aria-hidden="true">→</span>
                    </a>
                <#elseif client.baseUrl?has_content>
                    <a class="v-btn v-btn-ghost" href="${client.baseUrl}">
                        <span class="v-btn-label">${kcSanitize(msg("backToApplication"))?no_esc}</span>
                        <span class="v-btn-arrow" aria-hidden="true">→</span>
                    </a>
                </#if>
            </#if>
        </div>

    </#if>
</@layout.registrationLayout>

<#--
  Macro qui rend la colonne gauche "voix du maillage" pour un écran donné.
  Lit les clés maillage.<screen>.label et maillage.<screen>.line1..4 dans messages_<lang>.properties.
-->
<#macro voice screen showGoogleLine=false>
<aside class="kc-voice" data-screen="${screen}">
  <div class="kc-label">${msg("maillage." + screen + ".label")}</div>
  <div class="kc-lines">
    <#list 1..4 as i>
      <#assign key = "maillage." + screen + ".line" + i>
      <#assign val = msg(key)>
      <#if val?length gt 0 && val != key>
        <p class="kc-line is-pending" data-text="${val}"></p>
      </#if>
    </#list>
  </div>
  <#if showGoogleLine>
    <#assign gKey = "maillage." + screen + ".line_google">
    <#assign gVal = msg(gKey)>
    <#if gVal?length gt 0 && gVal != gKey>
      <p class="kc-line kc-line-aside">${gVal}</p>
    </#if>
  </#if>
  <#if screen == "login" || screen == "login-otp">
    <div class="kc-terminal-card" aria-hidden="true">
      <span class="kc-terminal-label">access</span>
    </div>
  </#if>
</aside>
</#macro>

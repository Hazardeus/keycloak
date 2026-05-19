<#import "_macros-maillage.ftl" as maillage>
<#macro registrationLayout bodyClass="" displayMessage=true displayRequiredFields=false displayWide=false showAnotherWayIfPresent=true voiceScreen="login" showGoogleLine=false>
<!DOCTYPE html>
<html lang="${locale.currentLanguageTag!'fr'}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${(realm.displayNameHtml!realm.displayName!realm.name)} — ${msg("loginTitle")}</title>
  <link rel="icon" href="${url.resourcesPath}/img/favicon.svg" type="image/svg+xml">
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body class="kc-body ${bodyClass}">

  <header class="kc-head">
    <a class="kc-brand" href="${url.loginUrl}">${realm.displayName!"yoops"}</a>
    <#if realm.internationalizationEnabled && (locale.supported?size > 1)>
      <nav class="kc-locale">
        <#list locale.supported as l>
          <a class="kc-locale-link <#if l.languageTag == locale.currentLanguageTag>is-current</#if>"
             href="${l.url}">${l.languageTag}</a>
        </#list>
      </nav>
    </#if>
  </header>

  <main class="kc-stage">
    <@maillage.voice screen=voiceScreen showGoogleLine=showGoogleLine/>
    <section class="kc-form">
      <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
        <div class="kc-error" data-message-type="${message.type}">${kcSanitize(message.summary)?no_esc}</div>
      </#if>
      <#nested "form">
      <#if displayRequiredFields>
        <p class="kc-aux"><small>${msg("requiredFields")}</small></p>
      </#if>
    </section>
  </main>

  <footer class="kc-foot">
    <span>© ${.now?string('yyyy')} ${realm.displayName!"yoops"}</span>
    <span>
      <a href="/privacy">${msg("legal.privacy")}</a>
      &nbsp;·&nbsp;
      <a href="/terms">${msg("legal.terms")}</a>
    </span>
  </footer>

  <script src="${url.resourcesPath}/js/maillage.js" defer></script>
</body>
</html>
</#macro>

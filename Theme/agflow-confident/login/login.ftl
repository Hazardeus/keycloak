<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') voiceScreen="login" showGoogleLine=(social?? && social.providers?has_content); section>

  <form id="kc-form-login" action="${url.loginAction}" method="post" novalidate="novalidate">

    <div class="kc-field">
      <label for="username">${msg("usernameOrEmail")}</label>
      <input id="username"
             name="username"
             type="email"
             autocomplete="username"
             autofocus
             value="${(login.username!'')}"
             aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
      <#if messagesPerField.existsError('username','password')>
        <span class="kc-error" aria-live="polite">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
      </#if>
    </div>

    <div class="kc-field">
      <label for="password">${msg("password")}</label>
      <input id="password" name="password" type="password" autocomplete="current-password"/>
    </div>

    <div class="kc-form-options">
      <#if realm.rememberMe && !usernameHidden??>
        <label class="kc-checkbox">
          <input type="checkbox" name="rememberMe" <#if login.rememberMe??>checked</#if>>
          <span>${msg("rememberMe")}</span>
        </label>
      </#if>
      <#if realm.resetPasswordAllowed>
        <a href="${url.loginResetCredentialsUrl}" class="kc-aux-link">${msg("doForgotPassword")}</a>
      </#if>
    </div>

    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>

    <button type="submit" name="login" id="kc-login">${msg("doLogIn")}</button>
  </form>

  <#if realm.password && social?? && social.providers?has_content>
    <div class="kc-divider"><span>${msg("login.or")}</span></div>
    <div class="kc-social">
      <#list social.providers as p>
        <a class="kc-social-btn kc-social-${p.alias}" href="${p.loginUrl}" data-provider="${p.alias}">
          <span class="kc-social-glyph">
            <#include "resources/img/social-${p.alias}.svg.ftl">
          </span>
          <span class="kc-social-label">${msg("login.continueWith", p.displayName!p.alias)}</span>
        </a>
      </#list>
    </div>
  </#if>

</@layout.registrationLayout>

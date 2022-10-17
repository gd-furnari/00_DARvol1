<?xml version="1.0" encoding="UTF-8"?>

<#-- Import a common module with predefined functions and macros: these functions can be used by using the name
given to the module, in this case "com" -->
<#import "macros_common_general.ftl" as com>

<#assign locale = "en" />
<#assign sysDateTime = .now>

<#-- Initialize the following variables:
	* _dossierHeader (:DossierHashModel) //The header document of a proper or 'raw' dossier, can be empty
	* _subject (:DocumentHashModel) //The dossier subject document or, if not in a dossier context, the root document, never empty
	-->
<@com.initializeMainVariables/>

<#--Initialize relevance-->
<@com.initiRelevanceForPPP relevance/>

<#-- get mixtures ("main" mixture + other representative products), active substance and metabolite datasets-->
<#if _subject.documentType=="MIXTURE">

    <#-- get the list of metabolite datasets in the dossier -->
    <#global _metabolites = com.getMetabolites(_subject)/>

    <#-- extract the active substance in the dossier -->
    <#assign activeSubstanceList = com.getComponents(_subject, "active substance") />
    <#if activeSubstanceList?has_content>
        <#assign activeSubstance = activeSubstanceList[0] />
    </#if>

    <#-- main mixture -->
    <#assign mixture = _subject/>

    <#-- other representative products-->
    <#assign otherProd = com.getOtherRepresentativeProducts(_subject)/>
    <#assign allProducts = [mixture] + otherProd/>

<#elseif _subject.documentType=="SUBSTANCE">
    <#assign activeSubstance=_subject/>
</#if>

<#--get legal entity and url-->
<#assign ownerLegalEntity = iuclid.getDocumentForKey(_subject.OwnerLegalEntity) />
<#assign docUrl=iuclid.webUrl.entityView(_subject.documentKey)/>


<#--if there is active substance create the report, otherwise just print an error -->
<#if activeSubstance??>

    <book version="5.0" xmlns="http://docbook.org/ns/docbook" xmlns:xi="http://www.w3.org/2001/XInclude">

        <#-- FIRST PAGE -->

        <#assign left_header_text = ''/>
        <#assign central_header_text = com.getReportSubject(rootDocument).name?html />
        <#assign right_header_text = ''/>

        <#assign left_footer_text = sysDateTime?string["dd/MM/yyyy"] + " - IUCLID 6 " + iuclid6Version!/>
        <#assign central_footer_text = 'N1 - Overall conclusions' />
        <#assign right_footer_text = ''/>

        <info>

            <title role="rule">
                <para role="i6header5_nobold"><#if ownerLegalEntity?has_content><@com.text ownerLegalEntity.GeneralInfo.LegalEntityName/></#if></para>

                <@com.emptyLine/>

                <para role="rule"/>
                <@com.emptyLine/>
                <ulink url="${docUrl}"><@com.text activeSubstance.ChemicalName/></ulink>

            </title>

            <subtitle>
                <para role="align-center"></para>
                <@com.emptyLine/>
                <para role="rule"/>
            </subtitle>

            <subtitle>
                <para role="align-right">
                    <para role="HEAD-3">DAR</para>
                    <@com.emptyLine/>
                    <para role="HEAD-4">Vol 1</para>
                    <@com.emptyLine/>
                    <@com.emptyLine/>
                </para>
            </subtitle>

            <cover>
                <para role="align-right">
                    <para role="cover.i6subtext">
                        ${left_footer_text}
                    </para>
                </para>
            </cover>
            <@com.metadataBlock left_header_text central_header_text right_header_text left_footer_text central_footer_text right_footer_text />
        </info>

        <#-- CHAPTERS -->
        <chapter label="6">
            <title>Impact on human and animal health</title>
            
            <sect1>
                <title>Effects having relevance to human and animal health</title>

                <sect2>
                    <title>Summary of adsorption, distribution, metabolism and excretion</title>

                    
                </sect2>

                <sect2>

                    <title>Summary of acute toxicity</title>

                    <#-- TODO - this section could be subdivided e.g. with sect3 into acute toxicity, irritation, skin sensitisation, phototoxicity 
                                    OR 
                                all the summaries / table put together in one single place adding a column in the tables indicating the endpoint (acute tox oral, acute tox dermal, etc)
                    -->

                    <#-- this macro prints the key information and discussion sections of the summary 
                    NOTE: the table of study comparison could also be included within the macro
                    -->
                    <#--  <@printSummary activeSubstance "ENDPOINT_SUMMARY" "AcuteToxicity"/>  -->
                </sect2>

                <#-- TODO: rest of subsections of 6.1 -->

            </sect1>
        
            <?hard-pagebreak?>
            
            <sect1>
                <title>Toxicological end point for assessment of risk following long-term dietary exposure - ADI</title>

                <#-- TODO -->
            </sect1>

        </chapter>

        <chapter label="7">
            <title>Residues</title>

            <#-- TODO -->
        </chapter>

    </book>

<#else>

    <book version="5.0" xmlns="http://docbook.org/ns/docbook" xmlns:xi="http://www.w3.org/2001/XInclude">
        <info>
            <title>The mixture does not contain an active substance! Please, add an active substance in the mixture composition and try again</title>
        </info>
        <part></part>
    </book>

</#if>

<#macro printSummary subject docType docSubtype>

<#-- NOTE: the code below should change to accommodate special cases 
                    -->
    <#-- Get document based on document type and document subtype for the active substance dataset -->
    <#assign docList = iuclid.getSectionDocumentsForParentKey(subject.documentKey, doctType, docSubType) />

    <#-- Set the flag to print name of document if more than one-->
    <#assign printDocName = docList?size gt 1 />

    <#-- Loop over the list and print relevant information -->
    <#list docList as doc>

        <@com.emptyLine/>

        <#-- print document name with URL if more than one exists -->
        <#if printDocName>

            <#-- get URL -->
            <#assign docUrl=iuclid.webUrl.documentView(doc.documentKey) />

            <para><emphasis role="underline">#${doc_index+1}:<ulink url="${docUrl}"><@com.text doc.name/></ulink></emphasis></para>
            <@com.emptyLine/>
        
        </#if>
        
        <#-- print Key Information section-->
        <para><emphasis role="bold">Key information: </emphasis></para>
        <para><@com.value doc.KeyInformation.KeyInformation/></para>
        <@com.emptyLine/>

        <#-- print Additional information section -->
        <para><emphasis role="bold">Additional information: </emphasis></para>
        <para><@com.value doc.Discussion.Discussion/></para>
        <@com.emptyLine/>
        
    </#list>


</#macro>


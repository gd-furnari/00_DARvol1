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
                    <para role="small">
                        <@printSummary activeSubstance "ENDPOINT_SUMMARY" "AcuteToxicity" "ORAL" />
                    </para>

                    <para role="small">
                        <@printSummary activeSubstance "ENDPOINT_SUMMARY" "AcuteToxicity" "INHALATION" />
                    </para>

                    <para role="small">
                        <@printSummary activeSubstance "ENDPOINT_SUMMARY" "AcuteToxicity" "DERMAL" />
                    </para>
                    
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

<#--  Print summary table on acute toxicity - Select "ORAL", "INHALATION" or "DERMAL" as a route -->
<#macro printSummary subject docType docSubtype route="ORAL">
    <#--  Parse Acute Toxicity document  -->
    <#--  Get document based on document type and document subtype for the active substance dataset  -->
    <#local summaryList = iuclid.getSectionDocumentsForParentKey(subject.documentKey, docType, docSubtype) />
    
    <#compress>
		<#--  CREATE TABLE  -->
        <table border="1">
            <#--  Assign title  -->
            <title>Summary table of animal studies on acute ${route?lower_case} toxicity</title>
            
            <#--  Define table header  -->
            <thead align="center" valign="middle">
                <tr><?dbfo bgcolor="#FBDDA6" ?>
                    <th>
                        <emphasis role="bold">
                            Method, guideline, deviations1 if any
                        </emphasis>
                    </th>
                    <th>
                        <emphasis role="bold">
                            Species, strain, sex, no/group
                        </emphasis>
                    </th>
                    <th>
                        <emphasis role="bold">
                            Test substance<#if route?upper_case == "INHALATION">, form and particle size (MMAD)</#if>
                        </emphasis>
                    </th>
                    <th>
                        <emphasis role="bold">
                            Dose levels, duration of exposure
                        </emphasis>
                    </th>
                    <th>
                        <emphasis role="bold">
                            Value LD50
                        </emphasis>
                    </th>
                    <th>
                        <emphasis role="bold">
                            Reference
                        </emphasis>
                    </th>
                </tr>
            </thead>
            
            <#--  Define table body  -->
            <tbody valign="middle">
                <#--  Loop over the summary list  -->
                <#list summaryList as summary>

                    <#if route?upper_case == "ORAL">
                        <#local studyRecordList = summary.KeyValueForChemicalSafetyAssessment.AcuteToxicityViaOralRoute.LinkToRelevantStudyRecords.StudyNameType />
                    <#elseif route?upper_case == "INHALATION">
                        <#local studyRecordList = summary.KeyValueForChemicalSafetyAssessment.AcuteToxicityViaInhalationRoute.LinkToRelevantStudyRecords.StudyNameType />
                    <#elseif route?upper_case == "DERMAL">
                        <#local studyRecordList = summary.KeyValueForChemicalSafetyAssessment.AcuteToxicityViaDermalRoute.LinkToRelevantStudyRecords.StudyNameType />
                    </#if>

                    <#--  Loop over the study record list  -->
                    <#list studyRecordList as item>
                        <#--  Get study record  -->
                        <#local studyRecord = iuclid.getDocumentForKey(item) />

                        <#--  Print necessary fields in row  -->
                        <#if studyRecord?has_content>
                            <tr>
                                <#--  Method, guideline, deviations cell  -->
                                <td>
                                    <#local studyRecordTestGuideline = studyRecord.MaterialsAndMethods.Guideline />

                                    <#if studyRecordTestGuideline?has_content>
                                        <#list studyRecordTestGuideline as row>
                                            <emphasis role="strong">Guideline: </emphasis>
                                            <@com.picklist row.Guideline />

                                            <sbr/>

                                            <emphasis role="strong">Deviation: </emphasis>
                                            <@com.picklist row.Deviation /><#if !row?is_last>,<@com.emptyLine/></#if>
                                        </#list>
                                    </#if>
                                </td>

                                <#--  Species, strain, sex cell  -->
                                <td>
                                    <#if studyRecord.MaterialsAndMethods.TestAnimals.Species?has_content>
                                        <emphasis role="strong">Species: </emphasis>
                                        <@com.picklist studyRecord.MaterialsAndMethods.TestAnimals.Species />

                                        <@com.emptyLine/>
                                    </#if>

                                    <#if studyRecord.MaterialsAndMethods.TestAnimals.Strain?has_content>
                                        <emphasis role="strong">Strain: </emphasis>
                                        <@com.picklist studyRecord.MaterialsAndMethods.TestAnimals.Strain />

                                        <@com.emptyLine/>
                                    </#if>

                                    <#if studyRecord.MaterialsAndMethods.TestAnimals.Sex?has_content>
                                        <emphasis role="strong">Sex: </emphasis>
                                        <@com.picklist studyRecord.MaterialsAndMethods.TestAnimals.Sex />
                                    </#if>
                                </td>

                                <#--  Test substance cell  -->
                                <td>
                                    <#--  Print test substance  -->
                                    <#local testMaterial = iuclid.getDocumentForKey(studyRecord.MaterialsAndMethods.TestMaterials.TestMaterialInformation) />
                                    <#if route?upper_case == "INHALATION">
                                        <emphasis role="strong">Test substance: </emphasis>
                                        <sbr/>
                                    </#if>

                                    <#if testMaterial?has_content>
                                        <#local testMaterialUrl=iuclid.webUrl.entityView(testMaterial.documentKey)/>

                                        <ulink url="${testMaterialUrl}"><@com.value testMaterial.Name/></ulink>
                                    <#else>
                                        No test substance available
                                    </#if>

                                    <#--  Print form and MMAD - only for inhalation route  -->
                                    <#if route?upper_case == "INHALATION">
                                        <@com.emptyLine/>

                                        <#--  Form  -->
                                        <emphasis role="strong">Form: </emphasis>
                                        <sbr/>
                                        TO BE CONFIRMED

                                        <#if studyRecord.MaterialsAndMethods.AdministrationExposure.TypeOfInhalationExposure?has_content>
                                            <#--  <@com.picklist studyRecord.MaterialsAndMethods.AdministrationExposure.TypeOfInhalationExposure />  -->
                                        <#else>
                                            No form available
                                        </#if>

                                        <@com.emptyLine/>

                                        <#--  MMAD  -->
                                        <emphasis role="strong">MMAD: </emphasis>
                                        <sbr/>

                                        <#if studyRecord.MaterialsAndMethods.AdministrationExposure.MassMedianAerodynamicDiameter?has_content>
                                            <@com.range studyRecord.MaterialsAndMethods.AdministrationExposure.MassMedianAerodynamicDiameter />
                                        <#else>
                                            No MMAD available
                                        </#if>
                                    </#if>
                                </td>

                                <#--  Dose levels, duration of exposure cell  -->
                                <td>
                                    <#--  Print dose levels - not for inhalation route  -->
                                    <#if route?upper_case != "INHALATION" && studyRecord.MaterialsAndMethods.AdministrationExposure.Doses?has_content>
                                        <emphasis role="strong">Dose levels: </emphasis><sbr/>
                                        <@com.text studyRecord.MaterialsAndMethods.AdministrationExposure.Doses />

                                        <@com.emptyLine/>
                                    </#if>

                                    <#--  Print duration of exposure - not for oral route  -->
                                    <#if route?upper_case != "ORAL" && studyRecord.MaterialsAndMethods.AdministrationExposure.DurationOfExposure?has_content>
                                        <emphasis role="strong">Duration of exposure: </emphasis><sbr/>
                                        <@com.value studyRecord.MaterialsAndMethods.AdministrationExposure.DurationOfExposure />
                                    </#if>
                                </td>

                                <#--  Value LD50 cell  -->
                                <td>
                                    <#if studyRecord.ResultsAndDiscussion.EffectLevels?has_content>
                                        <#list studyRecord.ResultsAndDiscussion.EffectLevels as row>
                                            <#if row.KeyResult == true && row.EffectLevel?has_content>
                                                <@com.range row.EffectLevel />
                                            </#if>
                                        </#list>
                                    </#if>
                                </td>

                                <#--  Reference cell  -->
                                <td></td>
                            </tr>
                        </#if>
                    </#list>
                </#list>
            </tbody>
        </table>
	</#compress>
</#macro>


<#macro printSummaryOld subject docType docSubtype>

<#-- NOTE: the code below should change to accommodate special cases 
                    -->
    <#-- Get document based on document type and document subtype for the active substance dataset -->
    <#assign docList = iuclid.getSectionDocumentsForParentKey(subject.documentKey, docType, docSubType) />

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


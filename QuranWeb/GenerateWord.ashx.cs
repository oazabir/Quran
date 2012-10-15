using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using System.IO;
using System.Text;
using QuranObjects;
using DocumentFormat.OpenXml;
using System.Text.RegularExpressions;
using DocumentFormat.OpenXml.Validation;
using System.Diagnostics;

namespace QuranWeb
{
    /// <summary>
    /// Summary description for GenerateWord
    /// </summary>
    public class GenerateWord : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            var surah = int.Parse(context.Request["surah"] ?? "1");
            var fileName = "Quran_Surah_" + surah + ".docx";
            //context.Response.AppendHeader("Content-Type", "application/vnd.openxmlformats-officedocument.wordprocessingml.document");
            context.Response.AppendHeader("Content-Type", "application/msword");
            context.Response.AppendHeader("Content-Disposition", "attachment; filename=" + fileName);
            //context.Response.ContentEncoding = Encoding.UTF8;

            // Open a Wordprocessing document for editing.
            var path = context.Server.MapPath("~/App_Data/" + fileName);
            if (File.Exists(path))
                File.Delete(path);

            File.Copy(context.Server.MapPath("~/App_Data/Template.docx"), path);
            using (WordprocessingDocument package = WordprocessingDocument.Open(path, true))
            {
                MainDocumentPart main = package.MainDocumentPart;
                StyleDefinitionsPart stylePart = main.StyleDefinitionsPart;
                FootnotesPart fpart = main.FootnotesPart;
                Body body = main.Document.Body;
                

                //MainDocumentPart main = package.AddMainDocumentPart();               
                //StyleDefinitionsPart stylePart = AddStylesPartToPackage(package);
                //CreateDefaultStyles(stylePart);
                //FootnotesPart fpart = main.AddNewPart<FootnotesPart>();
                
                //main.Document = new Document();
                //Body body = main.Document.AppendChild<Body>(new Body());
                //body.AppendChild(
                //    new SectionProperties(
                //        new FootnoteProperties(
                //            new NumberingFormat() { Val = NumberFormatValues.LowerLetter },
                //            new NumberingRestart() { Val = RestartNumberValues.EachPage })));

                using (var quran = new QuranObjects.QuranContext())
                {
                    var translations = from mt in quran.MyTranslations where mt.SurahNo == surah select mt;
                    var lastVersePara = new Paragraph();

                    foreach (var translation in translations)
                    {
                        // Emit headings as Heading 2
                        if (translation.Heading.Length > 0)
                        {
                            var headingPara = body.AppendChild<Paragraph>(
                                new Paragraph(new Run2(new Text2(translation.Heading))));
                            ApplyStyleToParagraph(stylePart, GetStyleIdFromStyleName(stylePart, "My Heading 2"), headingPara);

                            if (lastVersePara.ChildElements.OfType<Run>().Count() == 0)
                                lastVersePara.Remove();

                            lastVersePara = body.AppendChild<Paragraph>(new Paragraph());
                            ApplyStyleToParagraph(stylePart, GetStyleIdFromStyleName(stylePart, "Verse"), lastVersePara);
                        }

                        // Find all footnotes from the footnote translation
                        var footnotes = new List<string>();
                        var matches = new Regex(@"(\*+)([^\*]*)").Matches(translation.Footnote);
                        foreach (Match match in matches)
                        {
                            var footnoteText = match.Groups[2].Value;
                            footnotes.Add(footnoteText);
                        }

                        // Generate the verse number
                        var translationAyahNoEnglish = translation.AyahNo.ToString();
                        var banglaVerseNo = new String(Array.ConvertAll(translationAyahNoEnglish.ToCharArray(), (c) => (char)('০' + (char)(c - '0'))));
                        
                        AddSuperscriptText(lastVersePara, banglaVerseNo);
                        AddText(lastVersePara, " ", stylePart);

                        // Emit the translation while generating the footnote references
                        var translationFootnotes = new Regex(@"([^\*]*)(\*+)([^\*]*)").Matches(translation.Translation);
                        if (translationFootnotes.Count == 0)
                        {
                            AddText(lastVersePara, translation.Translation, stylePart);

                            // If there was no footnote marker in the translation text, then 
                            // add the entire footnote at the end of the translation
                            if (translation.Footnote.Trim().Length > 0)
                            {
                                var footnoteId = AddFootnoteReference(fpart, stylePart, translation.Footnote.Replace("*", ""));
                                AddFootnote(lastVersePara, footnoteId, stylePart);
                            }
                        }

                        foreach (Match match in translationFootnotes)
                        {
                            var beforeText = match.Groups[1].Value;
                            var footnoteMarker = match.Groups[2].Value;
                            var afterText = match.Groups[3].Value;

                            AddText(lastVersePara, beforeText, stylePart);

                            // Create a footnote first and then add a footnote reference
                            var footnoteId = AddFootnoteReference(fpart, stylePart, footnotes[footnoteMarker.Length-1]);
                            AddFootnote(lastVersePara, footnoteId, stylePart);
                            AddText(lastVersePara, afterText, stylePart);
                        }

                        if (lastVersePara.Parent == null)
                        {
                            ApplyStyleToParagraph(stylePart, GetStyleIdFromStyleName(stylePart, "Verse"), lastVersePara);
                            body.AppendChild(lastVersePara);
                        }

                        if (translation.NewParaAfterThis)
                        {
                            lastVersePara = body.AppendChild<Paragraph>(new Paragraph());
                            ApplyStyleToParagraph(stylePart, GetStyleIdFromStyleName(stylePart, "Verse"), lastVersePara);
                        }
                        else
                        {
                            AddText(lastVersePara, " ", stylePart);
                        }
                    }

                    if (lastVersePara.Parent == null)
                        body.AppendChild(lastVersePara);

                }

                package.MainDocumentPart.Document.Save();


                OpenXmlValidator validator = new OpenXmlValidator();
                int count = 0;
                foreach (ValidationErrorInfo error in
                    validator.Validate(package))
                {
                    count++;
                    Debug.WriteLine("Error " + count);
                    Debug.WriteLine("Description: " + error.Description);
                    Debug.WriteLine("ErrorType: " + error.ErrorType);
                    Debug.WriteLine("Node: " + error.Node);
                    Debug.WriteLine("Path: " + error.Path.XPath);
                    Debug.WriteLine("Part: " + error.Part.Uri);
                    Debug.WriteLine("-------------------------------------------");
                }
            }
            
            context.Response.TransmitFile(path);
        }

        private static string SanitizeText(string text)
        {
            //var englishRegex = new Regex(@"(\s*[\u0021-\u0029\u002F-\u003B\u0040-\u007E]{2,}\s*)+");
            //text = englishRegex.Replace(text, (match) => "<z>" + match.Value + "</z>");
            var arabicRegex = new Regex(@"[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]+");
            text = arabicRegex.Replace(text, (match) => "<x> " + match.Value + " </x>");

            text = text.Replace('ঃ', ':');

            return text;
        }

        private static void AddText(Paragraph p, string text, StyleDefinitionsPart stylePart)
        {
            //var characters = text.ToCharArray();
            //var arabicCharacters = characters.Where(c => c > '؁' && c < 'ݭ');
            //if (arabicCharacters.Count() > 0)
            //    Debug.WriteLine(arabicCharacters.ToArray());
            
            var regex = new Regex(@"([^<]*)<([^>]*)>([^<]*)</([^>]*)>([^<]*)");
            var matches = regex.Matches(text);
            if (matches.Count == 0)
            {
                text = SanitizeText(text);
                if (!text.Contains('<'))
                    p.AppendChild(new Run2(new Text2(text)));
                else
                    AddText(p, text, stylePart);
            }

            foreach (Match match in matches)
            {
                var beforeText = match.Groups[1].Value;
                var tag = match.Groups[2].Value;
                var insideText = match.Groups[3].Value;
                var afterText = match.Groups[5].Value;

                if (beforeText.Length > 0)
                {
                    beforeText = SanitizeText(beforeText);
                    if (!beforeText.Contains('<'))
                        p.AppendChild(new Run2(new Text2(beforeText)));
                    else
                        AddText(p, beforeText, stylePart);
                    
                }
                
                Run r = new Run2(new Text2(insideText));
                if (tag == "em")
                {
                    r.RunProperties.AppendChild(new Italic());
                    r.RunProperties.AppendChild(new ItalicComplexScript());
                }
                else if (tag == "b")
                {
                    r.RunProperties.AppendChild(new Bold());
                    r.RunProperties.AppendChild(new BoldComplexScript());
                }
                else if (tag == "sup")
                {
                    r.RunProperties.AppendChild(new VerticalTextAlignment() { Val = VerticalPositionValues.Superscript });
                }
                else if (tag == "x")
                {
                    // Arabic
                    r = new Run(new Text2(insideText));
                    r.RunProperties = new RunProperties { 
                        RightToLeftText = new RightToLeftText(),
                        RunFonts = new RunFonts { Ascii = "Arial", HighAnsi = "Arial" },
                        RunStyle = new RunStyle { Val = GetStyleIdFromStyleName(stylePart, "Arabic Char") } 
                    };
                }
                else if (tag == "z")
                {
                    // English
                    r = new Run(new Text2(insideText));
                    r.RunProperties = new RunProperties {
                        RunFonts = new RunFonts { Ascii = "Arial", HighAnsi = "Arial" },
                        RunStyle = new RunStyle { Val = GetStyleIdFromStyleName(stylePart, "English") } 
                    };                    
                }
                
                p.AppendChild(r);

                if (afterText.Length > 0)
                {
                    afterText = SanitizeText(afterText);
                    if (!afterText.Contains('<'))
                        p.AppendChild(new Run2(new Text2(afterText)));
                    else
                        AddText(p, afterText, stylePart);
                }
            }
        }

        /*private static void CreateDefaultStyles(StyleDefinitionsPart stylePart)
        {
            AddNewStyle(stylePart, "MyFootnoteText", "my footnote text", StyleValues.Paragraph,
                runStyle => 
                {
                    runStyle.AppendChild(new FontSize { Val = "24" });
                    runStyle.AppendChild(new FontSizeComplexScript { Val = "24" });
                },
                paraStyle =>
                {
                    paraStyle.AppendChild(new SpacingBetweenLines { 
                        After = "0", 
                        LineRule = LineSpacingRuleValues.Auto, 
                        Line = "240"
                    });
                });

            AddNewStyle(stylePart, "MyFootnoteReference", "my footnote reference", StyleValues.Character, 
                runStyle => 
                {
                    runStyle.AppendChild(new VerticalTextAlignment() { Val = VerticalPositionValues.Superscript });
                    runStyle.AppendChild(new FontSize { Val = "28" });
                    runStyle.AppendChild(new FontSizeComplexScript { Val = "28" });
                },
                paraStyle =>
                {
                    
                }, basedOn: null);

            AddNewStyle(stylePart, "MyFootnoteMarker", "my footnote marker", StyleValues.Character, runStyle =>
                {
                    runStyle.AppendChild(new VerticalTextAlignment() { Val = VerticalPositionValues.Superscript });
                    runStyle.AppendChild(new FontSize { Val = "28" });
                    runStyle.AppendChild(new FontSizeComplexScript { Val = "28" });
                },
                paraStyle => 
                {
                }, basedOn: null);

            AddNewStyle(stylePart, "Verse", "verse", StyleValues.Paragraph, runStyle =>
                {
                    runStyle.AppendChild(new FontSize { Val = "28" });
                    runStyle.AppendChild(new FontSizeComplexScript { Val = "28" });                
                },
                paraStyle =>
                {
                    paraStyle.AppendChild(new SpacingBetweenLines
                    {
                        After = "120",
                        LineRule = LineSpacingRuleValues.Auto
                    });
                });

            AddNewStyle(stylePart, "MyHeading", "My heading 2", StyleValues.Paragraph,
            runStyle =>
                {
                    runStyle.AppendChild(new FontSize { Val = "28" });
                    runStyle.AppendChild(new FontSizeComplexScript { Val = "28" });
                    runStyle.AppendChild(new Italic());
                    runStyle.AppendChild(new ItalicComplexScript());

                },
                paraStyle =>
                {
                    paraStyle.AppendChild(new SpacingBetweenLines
                    {
                        After = "0",
                        LineRule = LineSpacingRuleValues.Auto
                    });
                    paraStyle.AppendChild(new KeepNext { Val = OnOffValue.FromBoolean(true) });
                });
            
            AddNewStyle(stylePart, "English", "English Text", StyleValues.Character,
            runStyle =>
                {                                                
                    runStyle.AppendChild(new Font { Name = "Arial" });                
                    runStyle.AppendChild(new FontSize { Val = "20" });                
                },
                paraStyle =>
                {
                    paraStyle.AppendChild(new Font { Name = "Arial" });
                    paraStyle.AppendChild(new FontSize { Val = "20" });                
                });

            AddNewStyle(stylePart, "Arabic", "Arabic Text", StyleValues.Character,
            runStyle =>
                {           
                    runStyle.AppendChild(new Font { Name = "Arial" });
                    runStyle.AppendChild(new FontSize { Val = "36" });                    
                },
                paraStyle =>
                {
                    paraStyle.AppendChild(new Font { Name = "Arial" });
                    paraStyle.AppendChild(new FontSize { Val = "36" });                    
                });
        }*/

        private static void AddSuperscriptText(Paragraph p, string text)
        {
            Run run = new Run2(new Text2(text));
            run.RunProperties.AppendChild(
                new VerticalTextAlignment() { Val = VerticalPositionValues.Superscript });
            p.AppendChild(run);
        }

        private static void AddFootnote(Paragraph p, int id, StyleDefinitionsPart stylePart)
        {
            Run r = new Run(new FootnoteReference { Id = id });
            r.RunProperties = new RunProperties(
                //new RunFonts { Ascii = "Arial", HighAnsi = "Arial" }
                new RunStyle() { Val = GetStyleIdFromStyleName(stylePart, "My Footnote Reference") }
                );
                //new RunStyle() { Val = GetStyleIdFromStyleName(stylePart, "My Footnote Marker") });
            p.AppendChild(r);
        }

        /// <summary>
        /// Add a note to the FootNotes part and ensure it exists.
        /// </summary>
        /// <param name="description">The description of an acronym, abbreviation, some book references, ...</param>
        /// <returns>Returns the id of the footnote reference.</returns>
        private int AddFootnoteReference(FootnotesPart fpart, StyleDefinitionsPart stylePart, string description)
        {
            var footnotesRef = 0;
            if (fpart.Footnotes == null)
            {
                // Insert a new Footnotes reference
                new Footnotes(
                    new Footnote(
                        new Paragraph(
                            new ParagraphProperties(
                                new SpacingBetweenLines() 
                                    { After = "0", Before="0", Line = "240", LineRule = LineSpacingRuleValues.Auto }),
                                new Run2(
                                    new SeparatorMark())
                        )
                    ) { Type = FootnoteEndnoteValues.Separator, Id = -1 },
                    new Footnote(
                        new Paragraph(
                            new ParagraphProperties(
                                new SpacingBetweenLines() 
                                    {Before="0",  After = "0", Line = "240", LineRule = LineSpacingRuleValues.Auto }),
                                new Run2(
                                    new ContinuationSeparatorMark())
                        )
                    ) { Type = FootnoteEndnoteValues.ContinuationSeparator, Id = 0 }).Save(fpart);
                footnotesRef = 1;
            }
            else
            {
                // The footnotesRef Id is a required field and should be unique. You can assign yourself some hard-coded
                // value but that's absolutely not safe. We will loop through the existing Footnote
                // to retrieve the highest Id.
                foreach (var p in fpart.Footnotes.Elements<Footnote>())
                {
                    if (p.Id.HasValue && p.Id > footnotesRef) footnotesRef = (int)p.Id.Value;
                }
                footnotesRef++;
            }

            Run2 markerRun;
            Paragraph footnotePara = new Paragraph(
                        new ParagraphProperties(
                            new ParagraphStyleId() { Val = GetStyleIdFromStyleName(stylePart, "My Footnote Text") }),
                        markerRun = new Run2(
                            new RunProperties(
                                new RunStyle() { Val = GetStyleIdFromStyleName(stylePart, "My Footnote Reference") }),
                            new FootnoteReferenceMark())
                    );
            AddText(footnotePara, description, stylePart);

            fpart.Footnotes.AppendChild(
                new Footnote(
                    footnotePara     
                ) { Id = footnotesRef });

            //if (!styles.DoesStyleExists("footnote reference"))
            //{
            //    // Force the superscript style because if the footnote text style does not exists,
            //    // the rendering will be awful.
            //    markerRun.RunProperties.First().AppendChild(new VerticalTextAlignment() { Val = VerticalPositionValues.Superscript });
            //}
            fpart.Footnotes.Save();

            return footnotesRef;
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        // Apply a style to a paragraph.
        public static void ApplyStyleToParagraph(StyleDefinitionsPart part,
            string styleId, Paragraph p)
        {
            // If the paragraph has no ParagraphProperties object, create one.
            if (p.Elements<ParagraphProperties>().Count() == 0)
            {
                p.PrependChild<ParagraphProperties>(new ParagraphProperties());
            }

            // Get the paragraph properties element of the paragraph.
            ParagraphProperties pPr = p.Elements<ParagraphProperties>().First();
            
            // Set the style of the paragraph.
            pPr.ParagraphStyleId = new ParagraphStyleId() { Val = styleId };
        }

        // Return true if the style id is in the document, false otherwise.
        public static bool IsStyleIdInDocument(StyleDefinitionsPart part,
            string styleid)
        {
            // Get access to the Styles element for this document.
            Styles s = part.Styles;

            // Check that there are styles and how many.
            int n = s.Elements<Style>().Count();
            if (n == 0)
                return false;

            // Look for a match on styleid.
            Style style = s.Elements<Style>()
                .Where(st => (st.StyleId == styleid) && (st.Type == StyleValues.Paragraph))
                .FirstOrDefault();
            if (style == null)
                return false;

            return true;
        }

        // Return styleid that matches the styleName, or null when there's no match.
        public static string GetStyleIdFromStyleName(StyleDefinitionsPart stylePart, string styleName)
        {
            string styleId = stylePart.Styles.Descendants<StyleName>()
                .Where(s => s.Val.Value.Equals(styleName, StringComparison.InvariantCultureIgnoreCase)) 
                    //&& (((Style)s.Parent).Type == StyleValues.Paragraph))
                .Select(n => ((Style)n.Parent).StyleId).First();
            return styleId;
        }

        // Create a new style with the specified styleid and stylename and add it to the specified
        // style definitions part.
        private static void AddNewStyle(StyleDefinitionsPart styleDefinitionsPart,
            string styleid, string stylename, StyleValues type,
            Action<StyleRunProperties> prepareRunStyle, Action<StyleParagraphProperties> prepareParagraphStyle,
            string basedOn = "Normal")
        {
            // Get access to the root element of the styles part.
            Styles styles = styleDefinitionsPart.Styles;

            // Create a new paragraph style and specify some of the properties.
            Style style = new Style()
            {
                Type = type,
                StyleId = styleid,
                CustomStyle = true
            };
            StyleName styleName1 = new StyleName() { Val = stylename };            
            BasedOn basedOn1 = new BasedOn() { Val = basedOn };
            NextParagraphStyle nextParagraphStyle1 = new NextParagraphStyle() { Val = "Normal" };
            style.Append(styleName1);
            
            if (!string.IsNullOrEmpty(basedOn))
                style.Append(basedOn1);
            //style.Append(nextParagraphStyle1);

            // Create the StyleRunProperties object and specify some of the run properties.
            StyleRunProperties styleRunProperties = new StyleRunProperties();
            prepareRunStyle(styleRunProperties);
            // Add the run properties to the style.
            style.Append(styleRunProperties);

            StyleParagraphProperties styleParaProperties = new StyleParagraphProperties();
            prepareParagraphStyle(styleParaProperties);
            style.Append(styleParaProperties);            

            // Add the style to the styles part.
            styles.Append(style);
        }

        // Add a StylesDefinitionsPart to the document.  Returns a reference to it.
        public static StyleDefinitionsPart AddStylesPartToPackage(WordprocessingDocument doc)
        {
            StyleDefinitionsPart part;
            part = doc.MainDocumentPart.AddNewPart<StyleDefinitionsPart>();
            Styles root = new Styles();
            root.Save(part);
            return part;
        }
    }

    class Run2 : Run
    {
        public Run2() : base()
        {
            SetupRunProperties();
        }
        public Run2(IEnumerable<OpenXmlElement> childElements) : base(childElements)
        {
            SetupRunProperties();
        }
        public Run2(params OpenXmlElement[] childElements)
            : base(childElements)
        {
            SetupRunProperties();
        }

        private void SetupRunProperties()
        {            
            if (this.RunProperties == null)
                this.RunProperties = new RunProperties();

            this.RunProperties.Append(new ComplexScript(),
                    new Languages { Bidi = "bn-BD" }
                    //new FontSizeComplexScript { Val = "32" }
                );            
        }
    }

    class Text2 : Text
    {
        public Text2()
            : base()
        {
            Setup();
        }

        public Text2(string content)
            : base(content)
        {
            Setup();
        }

        private void Setup()
        {
            this.Space = SpaceProcessingModeValues.Preserve;
        }
    }
}
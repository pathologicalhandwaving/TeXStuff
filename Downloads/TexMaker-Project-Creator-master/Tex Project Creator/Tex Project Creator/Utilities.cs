using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tex_Project_Creator
{
    class ProjectUtilities
    {
        bool make_title = false;
        bool make_table_of_contents = false;
        string title = "";
        string author = "";
        string internalworkingPath = @"C://";
        string bibChapter = "";

        List<string> chapters = new List<string>();
        List<string> chapter_file_names = new List<string>();

        bool libNeeded = false;
        string workingPath = @"C:\";
        public void CreateFolderStructure(string projectName)
        {
            workingPath = internalworkingPath + @"\" + projectName + @"\";
            Directory.CreateDirectory(workingPath);
            Directory.CreateDirectory(workingPath+ "tex" );
            Directory.CreateDirectory(workingPath + "img");
            if(LibNeeded)
            {
                Directory.CreateDirectory(workingPath + "lib");
                File.Create(workingPath + @"lib\" + "library.bib");
            }
                

        }
        

        public string Path
        {
            get { return this.internalworkingPath; }
            set { this.internalworkingPath = value; }
        }
        

        public void CreateMainFile()
        {
            List<string> mainLines = new List<string>();
            mainLines.Add(@"\documentclass[10pt,a4paper]{article}");
            mainLines.Add(@"\usepackage[utf8]{inputenc}");
            mainLines.Add(@"\usepackage{amsmath}");
            mainLines.Add(@"\usepackage{amsfonts}");
            mainLines.Add(@"\usepackage{amssymb}");
            mainLines.Add(@"\usepackage{graphicx}");
            if(make_title == true)
            {
                mainLines.Add(@"\title{" + Title + "}");
            }
            mainLines.Add(@"\author{"+ Author + "}");
            mainLines.Add(@"\begin{document}");
            if(make_title == true)
            {
                mainLines.Add(@"\maketitle");
                mainLines.Add(@"\newpage");
            }
            if(make_table_of_contents == true)
            {
                mainLines.Add(@"\tableofcontents");
                mainLines.Add(@"\newpage");
            }
            for (int i = 0; i < chapter_file_names.Count; i++)
            {
                mainLines.Add(@"\input{tex/" + chapter_file_names[i] + "}");
                mainLines.Add(@"\newpage");
            }
            mainLines.Add(@"\end{document}");
            File.AppendAllLines(workingPath + "main.tex", mainLines);

        }

        public void addChapter(string newChap)
        {
            chapters.Add(newChap);
        }

        public void insertChapter(string newChap, int index)
        {
            chapters.Insert(index, newChap);
        }

        public bool createTitle
        {
            get { return this.make_title; }
            set { this.make_title = value; }
        }

        public bool createTable
        {
            get { return this.make_table_of_contents; }
            set { this.make_table_of_contents = value; }
        }

        public string Author { get => author; set => author = value; }
        public string Title { get => title; set => title = value; }
        public string BibChapter { get => bibChapter; set => bibChapter = value; }
        public bool LibNeeded { get => libNeeded; set => libNeeded = value; }

        public void CreateChapterFiles()
        {
            if(chapters.Count == 0)
            {
                throw new Exception("empty chapterlist");
            }
            List<string> sanitizedList = new List<string>();
            foreach (string s in chapters)
            {
                foreach (char c in System.IO.Path.GetInvalidFileNameChars())
                {
                    s.Replace(c, '_');
                }
                string filePath = workingPath + @"Tex\" + s + ".tex";
                chapter_file_names.Add('"'+s+".tex"+'"');
                if(LibNeeded && s == bibChapter)
                {
                    List<string> biblio = new List<string>();
                    biblio.Add(@"\section{" + s + "}");
                    biblio.Add(@"\bibliography{lib/library.bib}");
                    biblio.Add(@"\bibliographystyle{plain}");
                    File.AppendAllLines(filePath, biblio);
                }
                else
                {
                    File.WriteAllText(filePath, @"\section{" + s + "}");
                }
                
            }
        }
    }
}

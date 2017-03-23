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


        List<string> chapters = new List<string>();
        List<string> chapter_file_names = new List<string>();

        bool libNeeded = true;
        string workingPath = @"C:\";
        public void CreateFolderStructure(string path, string projectName)
        {
            workingPath = path + @"\" + projectName + @"\";
            Directory.CreateDirectory(workingPath);
            Directory.CreateDirectory(workingPath+ "tex" );
            Directory.CreateDirectory(workingPath + "img");
            if(libNeeded)
            {
                Directory.CreateDirectory(workingPath + "lib");
                File.Create(workingPath + @"lib\" + "library.bib");
            }
                

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
            if(title != "" && make_title == true)
            {
                mainLines.Add(@"\title{" + title + "}");
            }
            mainLines.Add(@"\author{"+ author + "}");
            mainLines.Add(@"\begin{document}");
            if(title != "" && make_title == true)
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

        public void CreateChapterFiles(List<string> chapterNames)
        {
            chapters = chapterNames;
            List<string> sanitizedList = new List<string>();
            foreach (string s in chapterNames)
            {
                foreach (char c in Path.GetInvalidFileNameChars())
                {
                    s.Replace(c, '_');
                    
                }
                string filePath = workingPath + @"Tex\" + s + ".tex";
                chapter_file_names.Add('"'+s+".tex"+'"');
                File.WriteAllText(filePath, @"\section{" + s + "}");
            }
        }
    }
}

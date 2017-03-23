using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tex_Project_Creator;

namespace Console_Library_TexMaker_Project
{
    class Program
    {
        static void Main(string[] args)
        {
            ProjectUtilities pu = new ProjectUtilities();
            pu.CreateFolderStructure(@"C:\\", "testproject");
            List<string> chapterNames = new List<string>();
            chapterNames.Add("First Chapter");
            chapterNames.Add("Second Chapter");
            chapterNames.Add("Third Chapter");
            chapterNames.Add("Fourth Chapter");
            pu.CreateChapterFiles(chapterNames);
            pu.CreateMainFile();
        }
    }
}  

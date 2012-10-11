namespace QuranObjects
{
    using System;
    using System.Data;
    using System.Data.Entity;
    using System.Data.SqlServerCe;
    using System.ComponentModel.DataAnnotations;
    using System.Data.Entity.Infrastructure;
    using System.Configuration;
    using System.Web.Hosting;
    using System.Collections.Generic;

    [Table("Ayahs")]
    public class Ayah
    {
        [Key]
        [DatabaseGenerated(System.ComponentModel.DataAnnotations.DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }

        public int SurahNo { get; set; }
        public int AyahNo { get; set; }
        public int TranslatorID { get; set; }

        [Required]
        public string Content { get; set; }

        [ForeignKey("TranslatorID")]
        public virtual Translator Translator { get; set; }
    }

    public class MyTranslation
    {
        [Key]
        [DatabaseGenerated(System.ComponentModel.DataAnnotations.DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public int SurahNo { get; set; }
        public int AyahNo { get; set; }
        public string Heading { get; set; }
        public string Translation { get; set; }
        public string Footnote { get; set; }
        public bool NewParaAfterThis { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime LastUpdateDate { get; set; }
    }

    public class Translator
    {
        [Key]
        [DatabaseGenerated(System.ComponentModel.DataAnnotations.DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }

        [Required]
        public string Name { get; set; }

        public int Order { get; set; }
        public int Type { get; set; }
        public bool ShowDefault { get; set; }
        public int LanguageID { get; set; }

        [InverseProperty("Translator")]
        public ICollection<Ayah> Ayahs { get; set; }

        [ForeignKey("LanguageID")]
        public virtual Language Language { get; set; }
    }

    public class ArabicWord
    {
        [Key]
        [DatabaseGenerated(System.ComponentModel.DataAnnotations.DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public int GrammarFormID { get; set; }
        public int RootID { get; set; }
        public string Arabic { get; set; }
        public int Occurences { get; set; }

        [ForeignKey("GrammarFormID")]
        public virtual GrammarForm GrammarForm { get; set; }
        [ForeignKey("RootID")]
        public virtual Root Root { get; set; }

        [InverseProperty("ArabicWord")]
        public ICollection<Meaning> Meanings { get; set; }
    }

    public class GrammarForm
    {
        [Key]
        [DatabaseGenerated(System.ComponentModel.DataAnnotations.DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public int RootID { get; set; }
        public string Grammar { get; set; }

        [ForeignKey("RootID")]
        public virtual Root Root { get; set; }

        [InverseProperty("GrammarForm")]
        public ICollection<ArabicWord> ArabicWords { get; set; }
        [InverseProperty("GrammarForm")]
        public ICollection<Meaning> Meanings { get; set; }
        
    }

    public class Meaning
    {
        [Key]
        [DatabaseGenerated(System.ComponentModel.DataAnnotations.DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public int SurahNo { get; set; }
        public int VerseNo { get; set; }
        public int WordNo { get; set; }
        public int ArabicWordID { get; set; }
        public string EnglishMeaning { get; set; }
        public int RootID { get; set; }
        public int GrammarFormID { get; set; }

        [ForeignKey("ArabicWordID")]
        public virtual ArabicWord ArabicWord { get; set; }
        [ForeignKey("RootID")]
        public virtual Root Root { get; set; }
        [ForeignKey("GrammarFormID")]
        public virtual GrammarForm GrammarForm { get; set; }

    }

    public class Root
    {
        [Key]
        [DatabaseGenerated(System.ComponentModel.DataAnnotations.DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public string RootCode { get; set; }
        public string RootEnglish { get; set; }
        public string RootArabic { get; set; }
        public string Meanings { get; set; }
        public string BanglaMeanings { get; set; }

        [InverseProperty("Root")]
        public ICollection<ArabicWord> ArabicWords { get; set; }
        [InverseProperty("Root")]
        public ICollection<GrammarForm> GrammarForms { get; set; }
        [InverseProperty("Root")]
        public ICollection<Meaning> WordMeanings { get; set; }
    }
    public class Language
    {
        [Key]
        public int ID { get; set; }
        [Required]
        public string Name { get; set; }

    }
    public class QuranContext : DbContext
    {
        public DbSet<Ayah> Ayahs { get; set; }
        public DbSet<Translator> Translators { get; set; }
        public DbSet<MyTranslation> MyTranslations { get; set; }
        public DbSet<Root> Roots { get; set; }
        public DbSet<Meaning> Meanings { get; set; }
        public DbSet<GrammarForm> GrammarForms { get; set; }
        public DbSet<ArabicWord> ArabicWords { get; set; }
        public DbSet<Language> Languages { get; set; }

        //public QuranContext()
        //    : base(ConfigurationManager.ConnectionStrings["QuranContext"].ConnectionString)
        //{
        //}

        static QuranContext() 
        {
            Database.SetInitializer(new QuranInitializer());

            //Database.DefaultConnectionFactory =
            //    new SqlConnectionFactory("Server=Microsoft SQL Server Compact Data Provider");
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Ayah>().ToTable("Ayahs");
            modelBuilder.Entity<Translator>().ToTable("Translators");
            modelBuilder.Entity<MyTranslation>().ToTable("MyTranslations");
            modelBuilder.Entity<ArabicWord>().ToTable("ArabicWords");
            modelBuilder.Entity<GrammarForm>().ToTable("GrammarForms");
            modelBuilder.Entity<Root>().ToTable("Roots");
            modelBuilder.Entity<Meaning>().ToTable("Meanings");
            modelBuilder.Entity<Language>().ToTable("Languages");

            modelBuilder.Entity<ArabicWord>().HasRequired(a => a.GrammarForm).WithMany(g => g.ArabicWords).HasForeignKey(a => a.GrammarFormID).WillCascadeOnDelete(false);
            modelBuilder.Entity<ArabicWord>().HasRequired(a => a.Root).WithMany(r => r.ArabicWords).HasForeignKey(a => a.RootID).WillCascadeOnDelete(false);

            modelBuilder.Entity<GrammarForm>().HasRequired(g => g.Root).WithMany(r => r.GrammarForms).HasForeignKey(g => g.RootID).WillCascadeOnDelete(false);

            modelBuilder.Entity<Meaning>().HasRequired(m => m.GrammarForm).WithMany(g => g.Meanings).HasForeignKey(m => m.GrammarFormID).WillCascadeOnDelete(false);
            modelBuilder.Entity<Meaning>().HasRequired(m => m.ArabicWord).WithMany(a => a.Meanings).HasForeignKey(m => m.ArabicWordID).WillCascadeOnDelete(false);
            modelBuilder.Entity<Meaning>().HasRequired(m => m.Root).WithMany(r => r.WordMeanings).HasForeignKey(m => m.RootID).WillCascadeOnDelete(false);

            modelBuilder.Entity<Ayah>().HasRequired(a => a.Translator).WithMany(t => t.Ayahs).HasForeignKey(a => a.TranslatorID).WillCascadeOnDelete(false);
        }
    }

    public class QuranInitializer : CreateDatabaseIfNotExists<QuranContext>
    {
        public QuranInitializer()
        {            
            //Database.DefaultConnectionFactory = new SqlConnectionFactory(
            //    ConfigurationManager.ConnectionStrings["Quran"].ConnectionString);    

            //Database.DefaultConnectionFactory = new SqlCeConnectionFactory("System.Data.SqlServerCe.4.0",
            //     HostingEnvironment.MapPath("~/App_Data/"),"");            
        }
        
        
    }
}

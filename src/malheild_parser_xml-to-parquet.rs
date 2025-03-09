use quick_xml::Reader;
use quick_xml::events::Event;
use std::fs::File;
use std::io::BufReader;
use arrow::datatypes::{Schema, Field, DataType};
use arrow::record_batch::RecordBatch;
use parquet::arrow::ArrowWriter;
use rayon::prelude::*;

fn process_file(input_path: &str, output_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let file = File::open(input_path)?;
    let reader = BufReader::new(file);
    let mut xml_reader = Reader::from_reader(reader);

    let mut word_counts = std::collections::HashMap::new();
    let mut bigram_counts = std::collections::HashMap::new();
    let mut trigram_counts = std::collections::HashMap::new();

    let mut buf = Vec::new();
    let mut words = Vec::new();

    loop {
        match xml_reader.read_event(&mut buf)? {
            Event::Text(e) => {
                let text = e.unescape_and_decode(&xml_reader)?;
                words.extend(text.split_whitespace().map(String::from));
                
                // Process words, bigrams, and trigrams
                for window in words.windows(3) {
                    *word_counts.entry(window[0].clone()).or_insert(0) += 1;
                    *bigram_counts.entry((window[0].clone(), window[1].clone())).or_insert(0) += 1;
                    *trigram_counts.entry((window[0].clone(), window[1].clone(), window[2].clone())).or_insert(0) += 1;
                }
                
                words.clear();
            }
            Event::Eof => break,
            _ => (),
        }
        buf.clear();
    }

    // Convert to Arrow RecordBatch
    let schema = Schema::new(vec![
        Field::new("word", DataType::Utf8, false),
        Field::new("count", DataType::Int64, false),
    ]);

    let word_data: Vec<_> = word_counts.into_iter().collect();
    let record_batch = RecordBatch::try_new(
        std::sync::Arc::new(schema),
        vec![
            arrow::array::StringArray::from(word_data.iter().map(|(w, _)| w.as_str()).collect::<Vec<_>>()),
            arrow::array::Int64Array::from(word_data.iter().map(|(_, c)| *c as i64).collect::<Vec<_>>()),
        ],
    )?;

    // Write to Parquet
    let output_file = File::create(output_path)?;
    let mut writer = ArrowWriter::try_new(output_file, record_batch.schema(), None)?;
    writer.write(&record_batch)?;
    writer.close()?;

    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let input_files = vec!["file1.xml", "file2.xml", "file3.xml"]; // Add your file paths here
    
    input_files.par_iter().try_for_each(|&input_file| {
        let output_file = input_file.replace(".xml", ".parquet");
        process_file(input_file, &output_file)
    })?;

    Ok(())
}

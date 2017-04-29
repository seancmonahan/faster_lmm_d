module faster_lmm_d.rqtlreader;

import std.stdio;
import std.string;
import std.array;
import std.csv;
import std.getopt;
import std.typecons;
import std.json;
import std.conv;
import std.range;
import std.file;
import std.experimental.logger;
import std.regex;
import dyaml.all;

import faster_lmm_d.dmatrix;

JSONValue control(string fn){
  string input = cast(string)std.file.read(fn);
  JSONValue j = parseJSON(input);
  return j;
}

int kinship(string fn){
  auto K1 = [][];
  log(fn);
  //string input = cast(string)std.file.read(fn);

  //string[] lines = input.split("\n");

  //int i = 0;
  //foreach(line; lines[3..$])
  //{
  //  log(line);
  //  //csvReader!int(lines[i],"\t");
  //  i++;
  //}
  auto file = File(fn);
  //log(file.byLine());

  return 1;
}

auto pheno(string fn, int p_column= 0){
  Regex!char Pattern = regex("\\.json$", "i");
  double[] y;
  string[] ynames;

  if(!match(fn, Pattern).empty)
  {
    Node gn2_pheno = Loader(fn).load();
    foreach(Node strain; gn2_pheno){
      //log(strain.as!string);
      y ~= strain[2].as!double;
      ynames ~= strain[1].as!string;
    }
    log("interest");
    log(y);
    log(ynames);
    log("interest");
  }
  return Tuple!(double[], string[])(y, ynames);
}

genoObj geno(string fn, JSONValue ctrl){

  trace("in geno function");

  //FIXME
  string s = `{"-" : "0","NA": "0", "U": "0"}`;
  ctrl["na-strings"] = parseJSON(s);
  //log(ctrl.object);
  int[string] hab_mapper;
  int idx = 0;

  foreach( key, value; ctrl["genotypes"].object){
    string a  = to!string(key);
    string b = to!string(value);
    int c = to!int(b);
    hab_mapper[a] = c;
    log(hab_mapper);
    log(b);

    idx++;
  }
  //log(hab_mapper);
  log(idx);
  assert(idx == 3);
  double[] faster_lmm_d_mapper = [double.nan, 0.0, 0.5, 1.0];
  //foreach(s; ctrl["na.strings"]){

  foreach( key,value; ctrl["na-strings"].object){
    idx += 1;
    hab_mapper[to!string(key)] = idx;
    faster_lmm_d_mapper ~= double.nan;
  }
  log("hab_mapper", hab_mapper);
  log("faster_lmm_d_mapper", faster_lmm_d_mapper);

  string input = cast(string)std.file.read(fn);
  auto tsv = csvReader!(string, Malformed.ignore)(input, null);

  string[] gnames = tsv.header[1..$];
  double[] gs2;
  int rowCount = 0;
  int colCount;
  string[] gs;
  foreach(row; tsv){
    string id = row.front;
    row.popFront();
    gs = [];
    colCount = 0;
    foreach(item; row){
      gs ~= item;
      gs2 ~= faster_lmm_d_mapper[hab_mapper[item]];
      colCount++;
    }
    rowCount++;
  }
  info("MATRIX CREATED");
  return genoObj(dmatrix([rowCount, colCount], gs2), gnames);
}


int geno_callback(string fn){
  int[string] hab_mapper;
  hab_mapper["A"] = 0;
  hab_mapper["H"] = 1;
  hab_mapper["B"] = 2;
  hab_mapper["-"] = 3;
  auto faster_lmm_d_mapper = [ 0.0, 0.5, 1.0, double.nan];

  //  raise "NYI"
  log(fn);

  auto file = File(fn); // Open for reading
  assert(file.readln().strip() == "# Genotype format version 1.0");
  file.readln();
  file.readln();
  file.readln();
  file.readln();

  string input = cast(string)std.file.read(fn);
  auto tsv = csvReader!(string, Malformed.ignore)(input, '\t');
  log(tsv);
  return 1;
}

int geno_iter(string fn){
  int[string] hab_mapper;
  hab_mapper["A"] = 0;
  hab_mapper["H"] = 1;
  hab_mapper["B"] = 2;
  hab_mapper["-"] = 3;
  auto faster_lmm_d_mapper = [ 0.0, 0.5, 1.0, double.nan];

  log(fn);


  auto file = File(fn); // Open for reading
  assert(file.readln() == "# Genotype format version 1.0");
  file.readln();
  file.readln();
  file.readln();
  file.readln();
  log(file);

  string input = cast(string)std.file.read(fn);
  auto tsv = csvReader!(string, Malformed.ignore)(input, '\t');
  log(tsv);

  return 1;
}
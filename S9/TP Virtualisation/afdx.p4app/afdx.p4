header_type afdx_header_t {
  fields {
    CST : 32;
    VL : 16;
    SRC : 48;
    TYPE : 16;
  }
} 

header afdx_header_t afdx_header ;


parser start {
       return parse_afdx_frame;
}

// à compléter pour gérer l'AFDX
parser parse_afdx_frame { 
    extract(afdx_header);
    return select(afdx_header.CST) {
      0x03000000 : ingress;
    }
}

action forward(port){
  modify_field(standard_metadata.egress_spec, port);
}

action _drop(){
  drop();
}

table afdx_table {
  reads{
    afdx_header.VL : exact;
  }
  actions{
    forward;
    _drop;
  }
}

control ingress {
	apply(afdx_table);
}

control egress {
	// ne pas modifier
}

       

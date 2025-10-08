module axil_decoder_addr_rd

    import axil_pkg ::*;

(
    input   logic                           aclk,
    input   logic                           aresetn,

    input   logic   [AXI_ADDR_WIDTH-1:0]    addr,
    output  logic   [NUMBER_SLAVE:0]        slv_valid,

    input   logic                           m_axil_arvalid,

    input   logic                           m_axil_rvalid,
    input   logic                           m_axil_rready
);

    logic           [NUMBER_SLAVE:0]        slv_valid_wire;

    genvar i;

    typedef enum logic 
    {  
        IDLE,
        HAND
    } state_type_dec;

    state_type_dec state_dec;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_dec <= IDLE;
            slv_valid <= '0;
        end else
        begin
            case (state_dec)
                IDLE:
                    begin
                        if (!m_axil_arvalid)
                        begin
                            state_dec <= IDLE;
                        end else
                        begin
                            state_dec <= HAND;
                            slv_valid <= slv_valid_wire;
                        end
                    end
                HAND:
                    begin
                        if (!(m_axil_rready && m_axil_rvalid))
                        begin
                            state_dec <= HAND; 
                        end else
                        begin
                            state_dec <= IDLE;
                            slv_valid <= 0;
                        end
                    end
            endcase
        end
    end

    generate
        for (i = 0; i < NUMBER_SLAVE; i++) begin : gen_slave
            assign slv_valid_wire[i] = (addr >= AXI_ADDR_OFFSET[i]) && (addr < (AXI_ADDR_OFFSET[i] + AXI_ADDR_RANGE[i]));
        end
    endgenerate

    assign slv_valid_wire[NUMBER_SLAVE] = ~|slv_valid_wire[NUMBER_SLAVE-1:0];

endmodule
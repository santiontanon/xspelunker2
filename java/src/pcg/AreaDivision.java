/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author santi
 */
public class AreaDivision {
    public AreaPoint root;  // entry point from the parent (including direction to get to the parent)
    public int divisionID;
    public AreaDivision parent;
    public int nDescendants = 0;  // number of tree nodes below (not including this one)
    public List<String> tags = new ArrayList<>();
    
    
    public AreaDivision(AreaPoint a_root, int a_id, AreaDivision a_parent)
    {
        root = a_root;
        divisionID = a_id;
        parent = a_parent;
    }
    
    
    @Override
    public String toString()
    {
        return "div(" + divisionID + ")";
    }
}
